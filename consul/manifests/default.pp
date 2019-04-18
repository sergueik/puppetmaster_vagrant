# -*- mode: puppet -*-
# vi: set ft=puppet :
node 'default' {
  $home = env('HOME')
  notify {"home=${home}":}
  $path = env('PATH')
  notify {"path=${path}":}
  include stdlib
}
