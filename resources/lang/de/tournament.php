<?php

/**
 *    Copyright 2015-2018 ppy Pty. Ltd.
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

return [
    'index' => [
        'header' => [
            'subtitle' => 'Eine Liste an aktiven, offiziell anerkannten Turnieren',
            'title' => 'Community-Turniere',
        ],
        'none_running' => 'Momentan laufen keine Turniere, schau später noch mal!',
        'registration_period' => 'Anmeldung: :start bis :end',
    ],

    'show' => [
        'banner' => '',
        'entered' => 'Du bist für dieses Turnier angemeldet',
        'info_page' => '',
        'login_to_register' => 'Um die Details zur Anmeldung sehen, :login!',
        'not_yet_entered' => 'Du bist nicht für dieses Turnier angemeldet.',
        'rank_too_low' => 'Sorry, aber dein Rang entspricht nicht den Anforderungen für dieses Turnier!',
        'registration_ends' => 'Die Anmeldungen enden am :date',

        'button' => [
            'cancel' => 'Anmeldung abbrechen',
            'register' => 'Meld\' mich an!',
        ],

        'state' => [
            'before_registration' => '',
            'ended' => '',
            'registration_closed' => '',
            'running' => '',
        ],
    ],
    'tournament_period' => ':start bis :end',
];
