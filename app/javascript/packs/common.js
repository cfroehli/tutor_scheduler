import Rails from "@rails/ujs";
Rails.start();

import Turbolinks from "turbolinks";
Turbolinks.start();

import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

import 'channels';

require.context('../images', true, /\.(?:png|jpg|gif|ico|svg)$/);

import 'css/fontawesome.scss';
import '@fortawesome/fontawesome-free';

import 'css/bootstrap4.scss';
import 'bootstrap';
