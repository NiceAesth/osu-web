/**
 *    Copyright (c) ppy Pty Ltd <contact@ppy.sh>.
 *
 *    This file is part of osu!web. osu!web is distributed with the hope of
 *    attracting more community contributions to the core ecosystem of osu!.
 *
 *    osu!web is free software: you can redistribute it and/or modify
 *    it under the terms of the Affero GNU General Public License version 3
 *    as published by the Free Software Foundation.
 *
 *    osu!web is distributed WITHOUT ANY WARRANTY; without even the implied
 *    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *    See the GNU Affero General Public License for more details.
 *
 *    You should have received a copy of the GNU Affero General Public License
 *    along with osu!web.  If not, see <http://www.gnu.org/licenses/>.
 */

import Dispatcher from 'dispatcher';
import NotificationJson from 'interfaces/notification-json';
import { route } from 'laroute';
import { debounce } from 'lodash';
import { action, observable, runInAction, autorun } from 'mobx';
import LegacyPmNotification from 'models/legacy-pm-notification';
import Notification from 'models/notification';
import RootDataStore from 'stores/root-data-store';
import Store from 'stores/store';

export default class NotificationStore extends Store {
  @observable notifications = new Map<number, Notification>();
  @observable pmNotification = new LegacyPmNotification();
  @observable unreadCount = 0;

  private debouncedSendQueued = debounce(this.sendQueued, 500);
  private queued = new Set<number>();
  private queuedXhr?: JQuery.jqXHR;

  @action
  flushStore() {
    this.notifications.clear();
  }

  get(id: number) {
    this.notifications.get(id);
  }

  @action
  queueMarkAsRead(notification: Notification) {
    if (notification.canMarkRead) {
      notification.isMarkingAsRead = true;
      this.queued.add(notification.id);
    }

    this.debouncedSendQueued();
  }

  sendQueued() {
    const ids = [...this.queued];
    if (ids.length === 0) { return; }

    this.queuedXhr = $.ajax({
      data: { ids },
      dataType: 'json',
      method: 'POST',
      url: route('notifications.mark-read'),
    });

    ids.forEach((id) => this.queued.delete(id));

    this.queuedXhr.then(() => {
      runInAction(() => {
        this.updateMarkedAsRead(ids);
      });
    }).always(() => {
      runInAction(() => {
        for (const id of ids) {
          const notification = this.notifications.get(id);
          if (notification != null) {
            notification.isMarkingAsRead = false;
          }
        }
      });
    });

    return this.queuedXhr;
  }

  @action
  updateMarkedAsRead(ids: number[]) {
    const notifications: Notification[] = [];
    // FIXME: map doesn't work?
    for (const id of ids) {
      const notification = this.notifications.get(id);
      if (notification != null) {
        notification.isRead = true;
        notifications.push(notification);
      }
    }

    if (notifications.length > 0) {
      this.root.notificationsRead = notifications;
    }
  }

  @action
  updateWithJson(json: NotificationJson) {
    let notification = this.notifications.get(json.id);

    if (notification == null) {
      notification = new Notification(json.id);
      this.notifications.set(notification.id, notification);
    }

    return notification.updateFromJson(json);
  }
}
