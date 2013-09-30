package { ['ruby-json', 'libjson-ruby']:
  ensure => present,
}

import "classes/*.pp"
import "definitions/*.pp"
