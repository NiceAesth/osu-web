###
# Copyright 2015 ppy Pty. Ltd.
#
# This file is part of osu!web. osu!web is distributed with the hope of
# attracting more community contributions to the core ecosystem of osu!.
#
# osu!web is free software: you can redistribute it and/or modify
# it under the terms of the Affero GNU General Public License version 3
# as published by the Free Software Foundation.
#
# osu!web is distributed WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with osu!web.  If not, see <http://www.gnu.org/licenses/>.
###
{div, h2, span} = React.DOM
el = React.createElement

class ProfilePage.Extra extends React.Component
  constructor: (props) ->
    super props

    @state =
      tabsSticky: false
      profileOrder: @props.profileOrder


  componentDidMount: =>
    @_removeListeners()
    $.subscribe 'profilePageExtra:tab.profileContentsExtra', @_modeSwitch
    $.subscribe 'stickyHeader.profileContentsExtra', @_tabsStick
    $(window).on 'throttled-scroll.profileContentsExtra', @_modeScan
    osu.pageChange()
    @_modeScan()

    $(@refs.pages).sortable
      cursor: 'move'
      handle: '.profile-extra__dragdrop-toggle'
      revert: 150
      scrollSpeed: 10
      update: (event, ui) =>
        @updateOrder ui.item


  componentWillUnmount: =>
    @_removeListeners()


  componentWillReceiveProps: =>
    osu.pageChange()


  _modeScan: =>
    return if @_scrolling

    pages = document.getElementsByClassName('js-profile-page-extra--scrollspy')
    return unless pages.length

    currentPage = null
    anchorHeight = window.innerHeight * 0.5

    if osu.bottomPage()
      @_setMode _.last(pages).dataset.id
      return

    # FIXME: I don't remember why this one scans from bottom while
    # the one in forum.refreshCounter does it from top.
    for page in pages by -1
      pageTop = page.getBoundingClientRect().top
      continue unless pageTop <= anchorHeight

      @_setMode page.dataset.id
      return

    @_setMode page.dataset.id


  _modeSwitch: (_e, mode) =>
    # Don't bother scanning the current position.
    # The result will be wrong when target page is too short anyway.
    @_scrolling = true

    target = @refs["page-#{mode}"]

    return unless target

    $(window).stop().scrollTo target, 500,
      onAfter: =>
        # Manually set the mode to avoid confusion (wrong highlight).
        # Scrolling will obviously break it but that's unfortunate result
        # from having the scrollspy marker at middle of page.
        @_setMode mode, =>
          # Doesn't work:
          # - part of state (callback, part of mode setting)
          # - simple variable in callback
          # Both still change the switch too soon.
          setTimeout (=> @_scrolling = false), 100
      # count for the tabs height
      offset: @refs.tabs.getBoundingClientRect().height * -1


  _removeListeners: ->
    $.unsubscribe '.profileContentsExtra'
    $(window).off '.profileContentsExtra'


  _setMode: (mode, callback) =>
    return if mode == @state.mode

    @setState mode: mode, callback


  _tabsStick: (_e, target) =>
    newState = (target == 'profile-extra-tabs')
    @setState(tabsSticky: newState) if newState != @state.tabsSticky

  updateOrder: (element) =>
    oldOrder = @state.profileOrder
    newOrder = $(@refs.pages).sortable('toArray', attribute: 'data-id')

    id = element.attr 'id'

    @setState profileOrder: newOrder

    $.ajax '/account/update-profile', {
      method: 'PUT',
      dataType: 'JSON',
      data: {
        'order': @state.profileOrder,
      },
      error: (jqHXR, textStatus, errorThrown) =>
        osu.ajaxError jqHXR

        @setState profileOrder: oldOrder

        position = (oldOrder.indexOf id) - 1
        prevElement = $('#' + oldOrder[position])

        element.insertAfter prevElement
    }


  render: =>
    return if @props.mode == 'me'

    withMePage = @props.userPage.html != '' || @props.withEdit

    tabsContainerClasses = 'hidden-xs profile-extra-tabs__container js-fixed-element'
    tabsClasses = 'profile-extra-tabs__items'
    if @state.tabsSticky
      tabsContainerClasses += ' profile-extra-tabs__container--fixed js-sticky-header--active'
      tabsClasses += ' profile-extra-tabs__items--fixed'

    div className: 'osu-layout__section osu-layout__section--extra',
      div
        className: 'profile-extra-tabs js-sticky-header'
        'data-sticky-header-target': 'profile-extra-tabs'
        ref: 'tabs'
        div
          className: tabsContainerClasses
          div className: 'osu-layout__row',
            div
              className: tabsClasses
              'data-sticky-header-id': 'profile-extra-tabs'
              @state.profileOrder.map (m) =>
                return if m == 'me' && !withMePage

                el ProfilePage.ExtraTab, key: m, mode: m, currentMode: @state.mode

      div className: 'osu-layout__row', ref: 'pages',
        @props.profileOrder.map (m) =>
          topClassName = 'js-profile-page-extra--scrollspy'

          elem =
            switch m
              when 'me'
                topClassName += ' hidden' unless withMePage
                props = userPage: @props.userPage, withEdit: @props.withEdit, user: @props.user
                ProfilePage.UserPage

              when 'recent_activities'
                props = recentActivities: @props.recentActivities
                ProfilePage.RecentActivities

              when 'kudosu'
                props = user: @props.user, recentlyReceivedKudosu: @props.recentlyReceivedKudosu
                ProfilePage.Kudosu

              when 'top_ranks'
                props = user: @props.user, scoresBest: @props.scoresBest, scoresFirst: @props.scoresFirst
                ProfilePage.TopRanks

              when 'beatmaps'
                props =
                  favouriteBeatmapSets: @props.favouriteBeatmapSets
                  rankedAndApprovedBeatmapSets: @props.rankedAndApprovedBeatmapSets
                ProfilePage.Beatmaps

              when 'medals'
                props = achievements: @props.achievements, allAchievements: @props.allAchievements
                ProfilePage.Medals

              when 'historical'
                props =
                  beatmapPlaycounts: @props.beatmapPlaycounts
                  rankHistories: @props.rankHistories
                  scores: @props.scores
                ProfilePage.Historical

              when 'performance'
                props = rankHistories: @props.rankHistories
                ProfilePage.Performance

          props.header =
            div
              key: 'header'
              h2 className: 'profile-extra__title', Lang.get("users.show.extra.#{m}.title")
              if @props.withEdit
                span className: 'profile-extra__dragdrop-toggle',
                  el Icon, name: 'bars'

          div
            key: m
            ref: "page-#{m}"
            'data-id': m
            className: topClassName
            el elem, props
