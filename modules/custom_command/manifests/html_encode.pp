# -*- mode: puppet -*-
# vi: set ft=puppet :

# this defined type intended to prepare
# shell scripts loaded from the hieradata
# to get written into the jenkins job configuration.
# this requires html encoding of the string which in hiera would me set like
# the '|' preserves line endings, the '>' converts them into spaces:
# NOTE: indent
# https://yaml-multiline.info
   #   custom_command::shell_command: |
   #     grep -Ei '(zipfile signature not found|filename not matched)' $LOG > /dev/null
   #     if [[ $? eq '0' ]\]
   #     then
   #       echo \"ERROR: 'ZIP' RETRY: '1'\"
   #     fi
   #
   #    # or
   #   custom_command::shell_command: >
   #     grep -Ei '(zipfile signature not found|filename not matched)' $LOG > /dev/null;
   #     if [[ $? eq '0' ]\];
   #     then;
   #       echo \"ERROR: 'ZIP' RETRY: '1'\";
   #     fi;
   #
define custom_command::html_encode(
  $version = '0.1.0',
  $shell_command_raw = hieradata('custom_command::shell_command', "grep -Ei '(zipfile signature not found|filenme not matched)' $LOG > /dev/null; if [[ $? eq '0' ]\] ; then echo \"ERROR: 'ZIP' RETRY: '1'\"; fi "),
)   {
  # validate parameters
  validate_string($shell_command_raw)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  # do HTML encoding
  # lint:ignore:double_quoted_string
  # https://stackoverflow.com/questions/7381974/which-characters-need-to-be-escaped-on-html
  # NOTE: the alterntive to '&#39;' is '&apos;'
  $shell_command = regsubst( regsubst( regsubst( regsubst( regsubst($shell_command_raw, '&', '&amp;', 'G'), '>', '&gt;', 'G'), '<', '&lt;', 'G'), '"', '&quot;' , 'G'), "'", '&#39;', 'G')
  #lint:endignore
  # mockup of the Jenkins job 'config.xml'
  file {"${job_path}/config.xml":
    content => template('confg_xml.erb'),
    notify  => Service['jenkins'],
    require => Package['jenkins'],
  }
}
