###
#    Copyright (c) ppy Pty Ltd <contact@ppy.sh>.
#
#    This file is part of osu!web. osu!web is distributed with the hope of
#    attracting more community contributions to the core ecosystem of osu!.
#
#    osu!web is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License version 3
#    as published by the Free Software Foundation.
#
#    osu!web is distributed WITHOUT ANY WARRANTY; without even the implied
#    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with osu!web.  If not, see <http://www.gnu.org/licenses/>.
###

import { createElement as el, PureComponent } from 'react'
import { ReportForm } from 'report-form'
import * as React from 'react'
import { a, button, div, i } from 'react-dom-factories'

export class ReportScore extends PureComponent
  constructor: (props) ->
    super props

    @state =
      completed: false
      disabled: false
      showingForm: false


  render: =>
    [
      button
        className: 'simple-menu__item'
        key: 'button'
        onClick: @showForm
        osu.trans 'report.scores.button'

      el ReportForm,
        completed: @state.completed
        disabled: @state.disabled
        key: 'form'
        onClose: @onFormClose
        onSubmit: @onSubmit
        title: osu.trans 'report.scores.title', username: "<strong>#{@props.score.user.username}</strong>"
        visible: @state.showingForm
        visibleOptions: ['Cheating', 'Other']
    ]


  onFormClose: =>
    @setState
      disabled: false
      showingForm: false


  showForm: (e) =>
    return if e.button != 0
    e.preventDefault()

    Timeout.clear @timeout
    @setState
      completed: false
      showingForm: true


  onSubmit: ({ comments, reason }) =>
    @setState disabled: true

    data =
      comments: comments
      reason: reason
      reportable_id: @props.score.id
      reportable_type: "score_best_#{@props.score.mode}"

    params =
      data: data
      dataType: 'json',
      type: 'POST',
      url: laroute.route('reports.store')

    $.ajax params
    .done () =>
      @timeout = Timeout.set 1000, @onFormClose
      @setState completed: true

    .fail (xhr) =>
      osu.ajaxError xhr
      @setState disabled: false
