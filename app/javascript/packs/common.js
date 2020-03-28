import Rails from "@rails/ujs";
Rails.start();

import Turbolinks from "turbolinks";
Turbolinks.start();

import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

import 'channels';

require.context('../images', true, /\.(?:png|jpg|gif|ico|svg)$/);

import '@fortawesome/fontawesome-free';
import 'bootstrap';
