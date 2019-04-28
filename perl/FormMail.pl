#!/usr/bin/perl -wT
#
# NMS FormMail Version 3.12c1
#

use strict;
use vars qw(
  $DEBUGGING $emulate_matts_code $secure %more_config
  $allow_empty_ref $max_recipients $mailprog @referers
  @allow_mail_to @recipients %recipient_alias
  @valid_ENV $date_fmt $style $send_confirmation_mail
  $confirmation_text $locale $charset $no_content
  $double_spacing $wrap_text $wrap_style $postmaster
);
# use strict;
use warnings;
# use 5.010;
# use Data::Dumper;
use Data::Dumper qw(Dumper);

BEGIN
{
  $DEBUGGING         = 1;
  $emulate_matts_code= 0;
  $secure            = 1;
  $allow_empty_ref   = 1;
  $max_recipients    = 5;
  $mailprog          = '/usr/sbin/sendmail -oi -t';
  $postmaster        = '';
  @referers          = qw(localhost athensstonecasting.com www.athensstonecasting.com);
  open (ALLOW, 'allowedRecipients') or die "open: $!";
  @allow_mail_to = map {/(\S+)/ ? ($1): ''} <ALLOW>;
  @recipients        = ();
  %recipient_alias   = ();
  @valid_ENV         = qw(REMOTE_HOST REMOTE_ADDR REMOTE_USER HTTP_USER_AGENT);
  $locale            = '';
  $charset           = 'iso-8859-1';
  $date_fmt          = '%A, %B %d, %Y at %H:%M:%S';
  $style             = '';
  $no_content        = 0;
  $double_spacing    = 1;
  $wrap_text         = 0;
  $wrap_style        = 1;
  $send_confirmation_mail = 0;
  $confirmation_text = <<'END_OF_CONFIRMATION';
From: you@your.com
Subject: form submission

Thank you for your form submission.

END_OF_CONFIRMATION

}

BEGIN {


$CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer_Sendmail = <<'END_INLINED_CGI_NMS_Mailer_Sendmail';
package CGI::NMS::Mailer::Sendmail;
use strict;

use IO::File;
BEGIN { 
do {
  unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Mailer}) {
    eval $CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer or die $@;
    $INC{'CGI/NMS/Mailer.pm'} = 1;
  }
  undef $CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer; # to save memory
};

 import CGI::NMS::Mailer }
use base qw(CGI::NMS::Mailer);

sub new {
  my ($pkg, $mailprog) = @_;

  return bless { Mailprog => $mailprog }, $pkg;
}

sub newmail {
  my ($self, $scriptname, $postmaster, @recipients) = @_;

  my $command = $self->{Mailprog};
  $command .= qq{ -f "$postmaster"} if $postmaster;
  my $pipe;
  eval { local $SIG{__DIE__};
         $pipe = IO::File->new("| $command");
       };
  if ($@) {
    die $@ unless $@ =~ /Insecure directory/;
    delete $ENV{PATH};
    $pipe = IO::File->new("| $command");
  }

  die "Can't open mailprog [$command]\n" unless $pipe;
  $self->{Pipe} = $pipe;

  $self->output_trace_headers($scriptname);
}

sub print {
  my ($self, @args) = @_;

  $self->{Pipe}->print(@args) or die "write to sendmail pipe: $!";
}

sub endmail {
  my ($self) = @_;

  $self->{Pipe}->close or die "close sendmail pipe failed, mailprog=[$self->{Mailprog}]";
  delete $self->{Pipe};
}

1;
  

END_INLINED_CGI_NMS_Mailer_Sendmail


$CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer_SMTP = <<'END_INLINED_CGI_NMS_Mailer_SMTP';
package CGI::NMS::Mailer::SMTP;
use strict;

use IO::Socket;
BEGIN { 
do {
  unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Mailer}) {
    eval $CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer or die $@;
    $INC{'CGI/NMS/Mailer.pm'} = 1;
  }
  undef $CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer; # to save memory
};

 import CGI::NMS::Mailer }
use base qw(CGI::NMS::Mailer);

sub new {
  my ($pkg, $mailhost) = @_;

  $mailhost .= ':25' unless $mailhost =~ /:/;
  return bless { Mailhost => $mailhost }, $pkg;
}

sub newmail {
  my ($self, $scriptname, $sender, @recipients) = @_;

  $self->{Sock} = IO::Socket::INET->new($self->{Mailhost});
  defined $self->{Sock} or die "connect to [$self->{Mailhost}]: $!";

  my $banner = $self->_smtp_response;
  $banner =~ /^2/ or die "bad SMTP banner [$banner] from [$self->{Mailhost}]";

  my $helohost = ($ENV{SERVER_NAME} =~ /^([\w\-\.]+)$/ ? $1 : '.');
  $self->_smtp_command("HELO $helohost");
  $self->_smtp_command("MAIL FROM:<$sender>");
  foreach my $r (@recipients) {
    $self->_smtp_command("RCPT TO:<$r>");
  }
  $self->_smtp_command("DATA", '3');

  $self->output_trace_headers($scriptname);
}

sub print {
  my ($self, @args) = @_;

  my $text = join '', @args;
  $text =~ s#\n#\015\012#g;
  $text =~ s#^\.#..#mg;

  $self->{Sock}->print($text) or die "write to SMTP socket: $!";
}

sub endmail {
  my ($self) = @_;

  $self->_smtp_command(".");
  $self->_smtp_command("QUIT");
  delete $self->{Sock};
}

sub _smtp_getline {
  my ($self) = @_;

  my $sock = $self->{Sock};
  my $line = <$sock>;
  defined $line or die "read from SMTP server: $!";

  return $line;
}

sub _smtp_response {
  my ($self) = @_;

  my $line = $self->_smtp_getline;
  my $resp = $line;
  while ($line =~ /^\d\d\d\-/) {
    $line = $self->_smtp_getline;
    $resp .= $line;
  }
  return $resp;
}

sub _smtp_command {
  my ($self, $command, $expect) = @_;
  defined $expect or $expect = '/usr/sbin/sendmail -oi -t';

  $self->{Sock}->print("$command\015\012") or die
    "write [$command] to SMTP server: $!";
  
  my $resp = $self->_smtp_response;
  unless (substr($resp, 0, 1) eq $expect) {
    die "SMTP command [$command] gave response [$resp]";
  }
}

1;
  

END_INLINED_CGI_NMS_Mailer_SMTP


$CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer = <<'END_INLINED_CGI_NMS_Mailer';
package CGI::NMS::Mailer;
use strict;

use POSIX qw(strftime);

sub output_trace_headers {
  my ($self, $traceinfo) = @_;

  $ENV{REMOTE_ADDR} =~ /^\[?([\d\.\:a-f]{7,100})\]?$/i or die
     "failed to get remote address from [$ENV{REMOTE_ADDR}], so can't send traceable email";
  $self->print("Received: from [$1]\n");

  my $me = ($ENV{SERVER_NAME} =~ /^([\w\-\.]{1,100})$/ ? $1 : 'unknown');
  $self->print("\tby $me ($traceinfo)\n");

  my $date = strftime '%a, %e %b %Y %H:%M:%S GMT', gmtime;
  $self->print("\twith HTTP; $date\n");

  if ($ENV{SCRIPT_NAME} =~ /^([\w\-\.\/]{1,100})$/) {
    $self->print("\t(script-name $1)\n");
  }

  if (defined $ENV{HTTP_HOST} and $ENV{HTTP_HOST} =~ /^([\w\-\.]{1,100})$/) {
    $self->print("\t(http-host $1)\n");
  }

  my $ff = $ENV{HTTP_X_FORWARDED_FOR};
  if (defined $ff) {
    $ff =~ /^\s*([\w\-\.\[\] ,]{1,200})\s*/ or die
      "malformed X-Forwarded-For [$ff], suspect attack, aborting";

    $self->print("\t(http-x-forwarded-for $1)\n");
  }

  my $ref = $ENV{HTTP_REFERER};
  if (defined $ref and $ref =~ /^([\w\-\.\/\:\;\%\@\#\~\=\+\?]{1,100})$/) {
    $self->print("\t(http-referer $1)\n");
  }
}

1;


END_INLINED_CGI_NMS_Mailer


unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Charset}) {
  eval <<'END_INLINED_CGI_NMS_Charset' or die $@;
package CGI::NMS::Charset;
use strict;

require 5.00404;

use vars qw($VERSION);
$VERSION = sprintf '%d.%.2d', (q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

sub new
{
   my ($pkg, $charset) = @_;

   my $self = { CHARSET => $charset };

   if ($charset =~ /^utf-8$/i)
   {
      $self->{SN} = \&_strip_nonprint_utf8;
      $self->{EH} = \&_escape_html_utf8;
   }
   elsif ($charset =~ /^iso-8859/i)
   {
      $self->{SN} = \&_strip_nonprint_8859;
      if ($charset =~ /^iso-8859-1$/i)
      {
         $self->{EH} = \&_escape_html_8859_1;
      }
      else
      {
         $self->{EH} = \&_escape_html_8859;
      }
   }
   elsif ($charset =~ /^us-ascii$/i)
   {
      $self->{SN} = \&_strip_nonprint_ascii;
      $self->{EH} = \&_escape_html_8859_1;
   }
   else
   {
      $self->{SN} = \&_strip_nonprint_weak;
      $self->{EH} = \&_escape_html_weak;
   }

   return bless $self, $pkg;
}

sub charset
{
   my ($self) = @_;

   return $self->{CHARSET};
}

sub escape
{
   my ($self, $string) = @_;

   return &{ $self->{EH} }(  &{ $self->{SN} }($string)  );
}

sub strip_nonprint_coderef
{
   my ($self) = @_;

   return $self->{SN};
}

sub escape_html_coderef
{
   my ($self) = @_;

   return $self->{EH};
}


use vars qw(%eschtml_map);
%eschtml_map = ( 
                 ( map {chr($_) => "&#$_;"} (0..255) ),
                 '<' => '&lt;',
                 '>' => '&gt;',
                 '&' => '&amp;',
                 '"' => '&quot;',
               );

sub _strip_nonprint_utf8
{
   my ($string) = @_;
   return '' unless defined $string;

   $string =~
   s%
    ( [\t\n\040-\176]               # printable us-ascii
    | [\xC2-\xDF][\x80-\xBF]        # U+00000080 to U+000007FF
    | \xE0[\xA0-\xBF][\x80-\xBF]    # U+00000800 to U+00000FFF
    | [\xE1-\xEF][\x80-\xBF]{2}     # U+00001000 to U+0000FFFF
    | \xF0[\x90-\xBF][\x80-\xBF]{2} # U+00010000 to U+0003FFFF
    | [\xF1-\xF7][\x80-\xBF]{3}     # U+00040000 to U+001FFFFF
    | \xF8[\x88-\xBF][\x80-\xBF]{3} # U+00200000 to U+00FFFFFF
    | [\xF9-\xFB][\x80-\xBF]{4}     # U+01000000 to U+03FFFFFF
    | \xFC[\x84-\xBF][\x80-\xBF]{4} # U+04000000 to U+3FFFFFFF
    | \xFD[\x80-\xBF]{5}            # U+40000000 to U+7FFFFFFF
    ) | .
   %
    defined $1 ? $1 : ' '
   %gexs;

   #
   # U+FFFE, U+FFFF and U+D800 to U+DFFF are dangerous and
   # should be treated as invalid combinations, according to
   # http://www.cl.cam.ac.uk/~mgk25/unicode.html
   #
   $string =~ s%\xEF\xBF[\xBE-\xBF]% %g;
   $string =~ s%\xED[\xA0-\xBF][\x80-\xBF]% %g;

   return $string;
}

sub _escape_html_utf8
{
   my ($string) = @_;

   $string =~ s|([^\w \t\r\n\-\.\,\x80-\xFD])| $eschtml_map{$1} |ge;
   return $string;
}

sub _strip_nonprint_weak
{
   my ($string) = @_;
   return '' unless defined $string;

   $string =~ s/\0+/ /g;
   return $string;
}
   
sub _escape_html_weak
{
   my ($string) = @_;

   $string =~ s/[<>"&]/$eschtml_map{$1}/eg;
   return $string;
}

sub _escape_html_8859_1
{
   my ($string) = @_;

   $string =~ s|([^\w \t\r\n\-\.\,\/\:])| $eschtml_map{$1} |ge;
   return $string;
}

sub _escape_html_8859
{
   my ($string) = @_;

   $string =~ s|([^\w \t\r\n\-\.\,\/\:\240-\377])| $eschtml_map{$1} |ge;
   return $string;
}

sub _strip_nonprint_8859
{
   my ($string) = @_;
   return '' unless defined $string;

   $string =~ tr#\t\n\040-\176\240-\377# #cs;
   return $string;
}

sub _strip_nonprint_ascii
{
   my ($string) = @_;
   return '' unless defined $string;

   $string =~ tr#\t\n\040-\176# #cs;
   return $string;
}


1;


END_INLINED_CGI_NMS_Charset
  $INC{'CGI/NMS/Charset.pm'} = 1;
}


unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Mailer::ByScheme}) {
  eval <<'END_INLINED_CGI_NMS_Mailer_ByScheme' or die $@;
package CGI::NMS::Mailer::ByScheme;
use strict;

sub new {
  my ($pkg, $argument) = @_;

  if ($argument =~ /^SMTP:([\w\-\.]+(:\d+)?)/i) {
    my $mailhost = $1;
    
do {
  unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Mailer::SMTP}) {
    eval $CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer_SMTP or die $@;
    $INC{'CGI/NMS/Mailer/SMTP.pm'} = 1;
  }
  undef $CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer_SMTP; # to save memory
};


    return CGI::NMS::Mailer::SMTP->new($mailhost);
  }
  else {
    
do {
  unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Mailer::Sendmail}) {
    eval $CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer_Sendmail or die $@;
    $INC{'CGI/NMS/Mailer/Sendmail.pm'} = 1;
  }
  undef $CGI::NMS::INLINED_SOURCE::CGI_NMS_Mailer_Sendmail; # to save memory
};


    return CGI::NMS::Mailer::Sendmail->new($argument);
  }
}

1;
  

END_INLINED_CGI_NMS_Mailer_ByScheme
  $INC{'CGI/NMS/Mailer/ByScheme.pm'} = 1;
}


unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Script}) {
  eval <<'END_INLINED_CGI_NMS_Script' or die $@;
package CGI::NMS::Script;
use strict;

use CGI;
use POSIX qw(locale_h strftime);
use CGI::NMS::Charset;

sub new {
  my ($pkg, @cfg) = @_;

  my $self = bless {}, $pkg;

  $self->{CFG} = {
    DEBUGGING           => 0,
    emulate_matts_code  => 0,
    secure              => 1,
    locale              => '',
    charset             => 'iso-8859-1',
    style               => '',
    cgi_post_max        => 1000000,
    cgi_disable_uploads => 1,

    $self->default_configuration,

    @cfg
  };

  $self->{Charset} = CGI::NMS::Charset->new( $self->{CFG}{charset} );

  $self->init;

  return $self;
}

sub request {
  my ($self) = @_;

  local ($CGI::POST_MAX, $CGI::DISABLE_UPLOADS);
  $CGI::POST_MAX        = $self->{CFG}{cgi_post_max};
  $CGI::DISABLE_UPLOADS = $self->{CFG}{cgi_disable_uploads};

  $ENV{PATH} =~ /(.*)/m or die;
  local $ENV{PATH} = $1;
  local $ENV{ENV}  = '';

  $self->{CGI} = CGI->new;
  $self->{Done_Header} = 0;

  my $old_locale;
  if ($self->{CFG}{locale}) {
    $old_locale = POSIX::setlocale( LC_TIME );
    POSIX::setlocale( LC_TIME, $self->{CFG}{locale} );
  }

  eval { local $SIG{__DIE__} ; $self->handle_request };
  my $err = $@;

  if ($self->{CFG}{locale}) {
    POSIX::setlocale( LC_TIME, $old_locale );
  }

  if ($err) {
    my $message;
    if ($self->{CFG}{DEBUGGING}) {
      $message = $self->escape_html($err);
    }
    else {
      $message = "See the web server's error log for details";
    }

    $self->output_cgi_html_header;
    print <<END;
 <head>
  <title>Error</title>
 </head>
 <body>
  <h1>Application Error</h1>
  <p>
   An error has occurred in the program
  </p>
  <p>
   $message
  </p>
 </body>
</html>
END

    $self->warn($err);
  }
}

sub output_cgi_html_header {
  my ($self) = @_;

  return if $self->{Done_Header};

  $self->output_cgi_header;

  unless ($self->{CFG}{no_xml_doc_header}) {
    print qq|<?xml version="1.0" encoding="$self->{CFG}{charset}"?>\n|;
  }

  unless ($self->{CFG}{no_doctype_doc_header}) {
    print <<END;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
END
  }

  if ($self->{CFG}{no_xmlns_doc_header}) {
    print "<html>\n";
  }
  else {
    print qq|<html xmlns="http://www.w3.org/1999/xhtml">\n|;
  }

  $self->{Done_Header} = 1;
}

sub output_cgi_header {
  my ($self) = @_;

  my $charset = $self->{CFG}{charset};
  my $cgi = $self->cgi_object;

  if ($CGI::VERSION >= 2.57) {
    # This is the correct way to set the charset
    print $cgi->header('-type'=>'text/html', '-charset'=>$charset);
  }
  else {
    # However CGI.pm older than version 2.57 doesn't have the
    # -charset option so we cheat:
    print $cgi->header('-type' => "text/html; charset=$charset");
  }
}

sub output_style_element {
  my ($self) = @_;

  if ($self->{CFG}{style}) {
    print qq|<link rel="stylesheet" type="text/css" href="$self->{CFG}{style}" />\n|;
  }
}

sub cgi_object {
  my ($self) = @_;

   return $self->{CGI};
}

sub param {
    my $self = shift;

    $self->cgi_object->param(@_);
}

sub escape_html {
  my ($self, $input) = @_;

  return $self->{Charset}->escape($input);
}

sub strip_nonprint {
  my ($self, $input) = @_;

  &{ $self->{Charset}->strip_nonprint_coderef }($input);
}

sub format_date {
  my ($self, $format_string, $gmt_offset) = @_;

  if (defined $gmt_offset and length $gmt_offset) {
    return strftime $format_string, gmtime(time + 60*60*$gmt_offset);
  }
  else {
    return strftime $format_string, localtime;
  }
}

sub name_and_version {
    my ($self) = @_;

    return $self->{CFG}{name_and_version};
}

sub warn {
    my ($self, $msg) = @_;

    if ($ENV{SCRIPT_NAME} =~ m#^([\w\-\/\.\:]{1,100})$#) {
        $msg = "$1: $msg";
    }

    if ($ENV{REMOTE_ADDR} =~ /^\[?([\d\.\:a-f]{7,100})\]?$/i) {
        $msg = "[$1] $msg";
    }

    warn "$msg\n";
}

sub init {}


1;


END_INLINED_CGI_NMS_Script
  $INC{'CGI/NMS/Script.pm'} = 1;
}


unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Validator}) {
  eval <<'END_INLINED_CGI_NMS_Validator' or die $@;
package CGI::NMS::Validator;
use strict;


sub validate_abs_url {
  my ($self, $url) = @_;

  $url = "http://$url" unless $url =~ /:/;
  $url =~ s#^(\w+://)# lc $1 #e;

  $url =~ m< ^ ( (?:ftp|http|https):// [\w\-\.]{1,100} (?:\:\d{1,5})? ) ( /* (?:[^\./].*)? ) $ >mx
    or return '';

  my ($prefix, $path) = ($1, $2);
  return $prefix unless length $path;

  $path = $self->validate_local_abs_uri_frag($path);
  return '' unless $path;
  
  return "$prefix$path";
}

sub validate_local_abs_uri_frag {
  my ($self, $frag) = @_;

  $frag =~ m< ^ ( (?: \.* /  [\w\-.!~*'(|);/\@+\$,%#&=]* )?
                  (?: \?     [\w\-.!~*'(|);/\@+\$,%#&=]* )?
                )
              $
           >x ? $1 : '';
}


sub validate_url {
  my ($self, $url) = @_;

  if ($url =~ m#://#) {
    $self->validate_abs_url($url);
  }
  else {
    $self->validate_local_abs_uri_frag($url);
  }
}


sub validate_email {
  my ($self, $email) = @_;

  $email =~ /^([a-z0-9_\-\.\*\+\=]{1,100})\@([^@]{2,100})$/i or return 0;
  my ($user, $host) = ($1, $2);

  return 0 if $host =~ m#^\.|\.$|\.\.#;

  if ($host =~ m#^\[\d+\.\d+\.\d+\.\d+\]$# or $host =~ /^[a-z0-9\-\.]+$/i ) {
     return "$user\@$host";
   }
   else {
     return 0;
  }
}

sub validate_realname {
  my ($self, $realname) = @_;

  $realname =~ tr# a-zA-Z0-9_\-,./'\200-\377# #cs;
  $realname = substr $realname, 0, 128;

  $realname =~ m#^([ a-zA-Z0-9_\-,./'\200-\377]*)$# or die "failed on [$realname]";
  return $1;
}


sub validate_html_color {
  my ($self, $color) = @_;

  $color =~ /^(#[0-9a-z]{6}|[\w\-]{2,50})$/i ? $1 : '';
}

1;


END_INLINED_CGI_NMS_Validator
  $INC{'CGI/NMS/Validator.pm'} = 1;
}


unless (eval {local $SIG{__DIE__} ; require CGI::NMS::Script::FormMail}) {
  eval <<'END_INLINED_CGI_NMS_Script_FormMail' or die $@;
package CGI::NMS::Script::FormMail;
use strict;

use vars qw($VERSION);
$VERSION = substr q$Revision: 1.10 $, 10, -1;

use Socket;  # for the inet_aton()

use CGI::NMS::Script;
use CGI::NMS::Validator;
use CGI::NMS::Mailer::ByScheme;
use base qw(CGI::NMS::Script CGI::NMS::Validator);

sub default_configuration {
  return ( 
    allow_empty_ref        => 1,
    max_recipients         => 5,
    mailprog               => '/usr/lib/sendmail -oi -t',
    postmaster             => '',
    referers               => [],
    allow_mail_to          => [],
    recipients             => [],
    recipient_alias        => {},
    valid_ENV              => [qw(REMOTE_HOST REMOTE_ADDR REMOTE_USER HTTP_USER_AGENT)],
    date_fmt               => '%A, %B %d, %Y at %H:%M:%S',
    date_offset            => '',
    no_content             => 0,
    double_spacing         => 1,
    join_string            => ' ',
    wrap_text              => 0,
    wrap_style             => 1,
  );
}

sub init {
  my ($self) = @_;

  if ($self->{CFG}{wrap_text}) {
    require Text::Wrap;
    import  Text::Wrap;
  }

  $self->{Valid_Env} = {  map {$_=>1} @{ $self->{CFG}{valid_ENV} }  };

  $self->init_allowed_address_list;

  $self->{Mailer} = CGI::NMS::Mailer::ByScheme->new($self->{CFG}{mailprog});
}


sub init_allowed_address_list {
  my ($self) = @_;

  my @allow_mail = ();
  my @allow_domain = ();

  foreach my $m (@{ $self->{CFG}{allow_mail_to} }) {
    if ($m =~ /\@/) {
      push @allow_mail, $m;
    }
    else {
      push @allow_domain, $m;
    }
  }

  my @alias_targets = split /\s*,\s*/, join ',', values %{ $self->{CFG}{recipient_alias} };
  push @allow_mail, grep /\@/, @alias_targets;

  # The username part of email addresses should be case sensitive, but the
  # domain name part should not.  Map all domain names to lower case for
  # comparison.
  my (%allow_mail, %allow_domain);
  foreach my $m (@allow_mail) {
    $m =~ /^([^@]+)\@([^@]+)$/ or die "internal failure [$m]";
    $m = $1 . '@' . lc $2;
    $allow_mail{$m} = 1;
  }
  foreach my $m (@allow_domain) {
    $m = lc $m;
    $allow_domain{$m} = 1;
  }

  $self->{Allow_Mail}   = \%allow_mail;
  $self->{Allow_Domain} = \%allow_domain;
}


sub handle_request {
  my ($self) = @_;

  $self->{Hide_Recipient} = 0;

  my $referer = $self->cgi_object->referer;
  unless ($self->referer_is_ok($referer)) {
    $self->referer_error_page;
    return;
  }

  $self->check_method_is_post    or return;

  $self->parse_form;

  $self->check_recipients( $self->get_recipients ) or return;

  my @missing = $self->get_missing_fields;
  if (scalar @missing) {
    $self->missing_fields_output(@missing);
    return;
  }

  my $date     = $self->date_string;
  my $email    = $self->get_user_email;
  my $realname = $self->get_user_realname;

  $self->send_main_email($date, $email, $realname);
  $self->send_conf_email($date, $email, $realname);

  $self->success_page($date);
}


sub date_string {
  my ($self) = @_;

  return $self->format_date( $self->{CFG}{date_fmt},
                             $self->{CFG}{date_offset} );
}

sub referer_is_ok {
  my ($self, $referer) = @_;

  unless ($referer) {
    return ($self->{CFG}{allow_empty_ref} ? 1 : 0);
  }

  if ($referer =~ m!^https?://([^/]*\@)?([\w\-\.]+)!i) {
    my $refhost = $2;
    return $self->refering_host_is_ok($refhost);
  }
  else {
    return 0;
  }
}

sub refering_host_is_ok {
  my ($self, $refhost) = @_;

  my @allow = @{ $self->{CFG}{referers} };
  return 1 unless scalar @allow;

  foreach my $test_ref (@allow) {
    if ($refhost =~ m|\Q$test_ref\E$|i) {
      return 1;
    }
  }

  my $ref_ip = inet_aton($refhost) or return 0;
  foreach my $test_ref (@allow) {
    next unless $test_ref =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;

    my $test_ref_ip = inet_aton($test_ref) or next;
    if ($ref_ip eq $test_ref_ip) {
      return 1;
    }
  }
}

sub referer_error_page {
  my ($self) = @_;

  my $referer = $self->cgi_object->referer || '';
  my $escaped_referer = $self->escape_html($referer);

  if ( $referer =~ m|^https?://([\w\.\-]+)|i) {
    my $host = $1;
    $self->error_page( 'Bad Referrer - Access Denied', <<END );
<p>
  The form attempting to use this script resides at <tt>$escaped_referer</tt>,
  which is not allowed to access this program.
</p>
<p>
  If you are attempting to configure FormMail to run with this form,
  you need to add the following to \@referers, explained in detail in the
  README file.
</p>
<p>
  Add <tt>'$host'</tt> to your <tt><b>\@referers</b></tt> array.
</p>
END
  }
  elsif (length $referer) {
    $self->error_page( 'Malformed Referrer - Access Denied', <<END );
<p>
  The referrer value <tt>$escaped_referer</tt> cannot be parsed, so
  it is not possible to check that the referring page is allowed to
  access this program.
</p>
END
  }
  else {
    $self->error_page( 'Missing Referrer - Access Denied', <<END );
<p>
  Your browser did not send a <tt>Referer</tt> header with this
  request, so it is not possible to check that the referring page
  is allowed to access this program.
</p>
END
  }
}

sub check_method_is_post {
  my ($self) = @_;

  return 1 unless $self->{CFG}{secure};

  my $method = $self->cgi_object->request_method || '';
  if ($method ne 'POST') {
    $self->error_page( 'Error: GET request', <<END );
<p>
  The HTML form fails to specify the POST method, so it would not
  be correct for this script to take any action in response to
  your request.
</p>
<p>
  If you are attempting to configure this form to run with FormMail,
  you need to set the request method to POST in the opening form tag,
  like this:
  <tt>&lt;form action=&quot;/cgi-bin/FormMail.pl&quot; method=&quot;post&quot;&gt;</tt>
</p>
END
    return 0;
  }
  else {
    return 1;
  }
}

sub parse_form {
  my ($self) = @_;

  $self->{FormConfig} = { map {$_=>''} $self->configuration_form_fields };
  $self->{Field_Order} = [];
  $self->{Form} = {};

  foreach my $p ($self->cgi_object->param()) {
    if (exists $self->{FormConfig}{$p}) {
      $self->parse_config_form_input($p);
    }
    else {
      $self->parse_nonconfig_form_input($p);
    }
  }

  $self->substitute_forced_config_values;

  $self->expand_list_config_items;

  $self->sort_field_order;
  $self->remove_blank_fields;
}

sub configuration_form_fields {
  qw(
    recipient
    subject
    email
    realname
    redirect
    bgcolor
    background
    link_color
    vlink_color
    text_color
    alink_color
    title
    sort
    print_config
    required
    env_report
    return_link_title
    return_link_url
    print_blank_fields
    missing_fields_redirect
recipient
  );
}

sub parse_config_form_input {
  my ($self, $name) = @_;

  my $val = $self->strip_nonprint($self->cgi_object->param($name));
  if ($name =~ /return_link_url|redirect$/) {
    $val = $self->validate_url($val);
  }
  $self->{FormConfig}{$name} = $val;
  unless ($self->{CFG}{emulate_matts_code}) {
    $self->{Form}{$name} = $val;
    if ( $self->{CFG}{"include_config_$name"} ) {
      push @{ $self->{Field_Order} }, $name;
    }
  }
}

sub parse_nonconfig_form_input {
  my ($self, $name) = @_;

  my @vals = map {$self->strip_nonprint($_)} $self->cgi_object->param($name);
  my $key = $self->strip_nonprint($name);
  $self->{Form}{$key} = join $self->{CFG}{join_string}, @vals;
  push @{ $self->{Field_Order} }, $key;
}

sub expand_list_config_items {
  my ($self) = @_;

  foreach my $p (qw(required env_report print_config)) {
    if ($self->{FormConfig}{$p}) {
      $self->{FormConfig}{$p} = [split(/\s*,\s*/, $self->{FormConfig}{$p})];
    }
    else {
      $self->{FormConfig}{$p} = [];
    }
  }

  $self->{FormConfig}{env_report} =
     [ grep { $self->{Valid_Env}{$_} } @{ $self->{FormConfig}{env_report} } ];
}

sub substitute_forced_config_values {
  my ($self) = @_;

  foreach my $k (keys %{ $self->{FormConfig} }) {
    if (exists $self->{CFG}{"force_config_$k"}) {
      $self->{FormConfig}{$k} = $self->{CFG}{"force_config_$k"};
      $self->{Hide_Recipient} = 1 if $k eq 'recipient';
    }
  }
}

sub sort_field_order {
  my ($self) = @_;

  my $sort = $self->{FormConfig}{'sort'};
  if (defined $sort) {
    if ($sort eq 'alphabetic') {
      $self->{Field_Order} = [ sort @{ $self->{Field_Order} } ];
    }
    elsif ($sort =~ /^\s*order:\s*(.*)$/s) {
      $self->{Field_Order} = [ split /\s*,\s*/, $1 ];
    }
  }
}

sub remove_blank_fields {
  my ($self) = @_;

  return if $self->{FormConfig}{print_blank_fields};

  $self->{Field_Order} = [
    grep { defined $self->{Form}{$_} and $self->{Form}{$_} !~ /^\s*$/ } 
    @{ $self->{Field_Order} }
  ];
}


sub get_recipients {
  my ($self) = @_;

  my $recipient = $self->{FormConfig}{recipient};
  my @recipients;

  if (length $recipient) {
    foreach my $r (split /\s*,\s*/, $recipient) {
      if (exists $self->{CFG}{recipient_alias}{$r}) {
        push @recipients, split /\s*,\s*/, $self->{CFG}{recipient_alias}{$r};
        $self->{Hide_Recipient} = 1;
      }
      else {
        push @recipients, $r;
      }
    }
  }
  else {
    return $self->default_recipients;
  }

  return @recipients;
}

sub default_recipients {
  my ($self) = @_;

  my @allow = grep {/\@/} @{ $self->{CFG}{allow_mail_to} };
  if (scalar @allow > 0 and not $self->{CFG}{emulate_matts_code}) {
    $self->{Hide_Recipient} = 1;
    return ($allow[0]);
  }
  else {
    return ();
  }
}

sub check_recipients {
  my ($self, @recipients) = @_;

  my @valid = grep { $self->recipient_is_ok($_) } @recipients;
  $self->{Recipients} = \@valid;

  if (scalar(@valid) == 0) {
    $self->bad_recipient_error_page;
    return 0;
  }
  elsif ($self->{CFG}{max_recipients} and scalar(@valid) > $self->{CFG}{max_recipients}) {
    $self->too_many_recipients_error_page;
    return 0;
  }
  else {
    return 1;
  }
}

sub recipient_is_ok {
  my ($self, $recipient) = @_;

  return 0 unless $self->validate_email($recipient);

  $recipient =~ /^(.+)\@([^@]+)$/m or die "regex failure [$recipient]";
  my ($user, $host) = ($1, lc $2);
  return 1 if exists $self->{Allow_Domain}{$host};
  return 1 if exists $self->{Allow_Mail}{"$user\@$host"};

  foreach my $r (@{ $self->{CFG}{recipients} }) {
    return 1 if $recipient =~ /(?:$r)$/;
    return 1 if $self->{CFG}{emulate_matts_code} and $recipient =~ /(?:$r)$/i;
  }

  return 0;
}

sub bad_recipient_error_page {
  my ($self) = @_;
  my $x = $self->{FormConfig};
  my @y =  keys %$x;
  my $t = {'a' => 1 };
  print STDERR join( ',', @y), "\n";
  # print Data::Dumper->Dump(@y);
  # print STDERR Dumper(@y);
  # return;
  my $errhtml = <<END;
<p>
  There was no recipient or an invalid recipient specified in the
  data sent to FormMail. Please make sure you have filled in the
  <tt>recipient</tt> form field with an e-mail address that has
  been configured in <tt>\@recipients</tt> or <tt>\@allow_mail_to</tt>.
  More information on filling in <tt>recipient/allow_mail_to</tt>
  form fields and variables can be found in the README file.
</p>
END
  unless ($self->{CFG}{force_config_recipient}) {
    my $esc_rec = $self->escape_html( $self->{FormConfig}{recipient} );
    $errhtml .= <<END;
<hr size="1" />
<p>
 The recipient was: [ $esc_rec ]
</p>
END
  }

  $self->error_page( 'Error: Bad or Missing Recipient', $errhtml );
}

sub too_many_recipients_error_page {
  my ($self) = @_;

  $self->error_page( 'Error: Too many Recipients', <<END );
<p>
  The number of recipients configured in the form exceeds the
  maximum number of recipients configured in the script.  If
  you are attempting to configure FormMail to run with this form
  then you will need to increase the <tt>\$max_recipients</tt>
  configuration setting in the script.
</p>
END
}

sub get_missing_fields {
  my ($self) = @_;

  my @missing = ();

  foreach my $f (@{ $self->{FormConfig}{required} }) {
    if ($f eq 'email') {
      unless ( $self->get_user_email =~ /\@/ ) {
        push @missing, 'email (must be a valid email address)';
      }
    }
    elsif ($f eq 'realname') { 
      unless ( length $self->get_user_realname ) {
        push @missing, 'realname';
      }
    }
    else {
      my $val = $self->{Form}{$f};
      if (! defined $val or $val =~ /^\s*$/) {
        push @missing, $f;
      }
    }
  }

  return @missing;
}

sub missing_fields_output {
  my ($self, @missing) = @_;

  if ( $self->{FormConfig}{'missing_fields_redirect'} ) {
    print $self->cgi_object->redirect($self->{FormConfig}{'missing_fields_redirect'});
  }
  else {
    my $missing_field_list = join '',
                             map { '<li>' . $self->escape_html($_) . "</li>\n" }
                             @missing;
    $self->error_page( 'Error: Blank Fields', <<END );
<p>
    The following fields were left blank in your submission form:
</p>
<div class="c2">
   <ul>
     $missing_field_list
   </ul>
</div>
<p>
    These fields must be filled in before you can successfully
    submit the form.
</p>
<p>
    Please use your back button to return to the form and
    try again.
</p>
END
  }
}

sub get_user_email {
  my ($self) = @_;

  my $email = $self->{FormConfig}{email};
  $email = $self->validate_email($email);
  $email = 'nobody' unless $email;

  return $email;
}

sub get_user_realname {
  my ($self) = @_;

  my $realname = $self->{FormConfig}{realname};
  if (defined $realname) {
    $realname = $self->validate_realname($realname);
  } else {
    $realname = '';
  }

  return $realname;
}

sub send_main_email {
  my ($self, $date, $email, $realname) = @_;

  my $mailer = $self->mailer;
  $mailer->newmail($self->name_and_version, $self->{CFG}{postmaster}, @{ $self->{Recipients} });

  $self->send_main_email_header($email, $realname);
  $mailer->print("\n");

  $self->send_main_email_body_header($date);

  $self->send_main_email_print_config;

  $self->send_main_email_fields;

  $self->send_main_email_footer;

  $mailer->endmail;
}

sub send_main_email_header {
  my ($self, $email, $realname) = @_;

  my $subject = $self->{FormConfig}{subject} || 'WWW Form Submission';
  if ($self->{CFG}{secure}) {
    $subject = substr($subject, 0, 256);
  }
  $subject =~ s#[\r\n\t]+# #g;

  my $to = join ',', @{ $self->{Recipients} };
  my $from = (length $realname ? "$email ($realname)" : $email);

  $self->mailer->print(<<END);
X-Mailer: ${\( $self->name_and_version )}
To: $to
From: $from
Subject: $subject
END
}

sub send_main_email_body_header {
  my ($self, $date) = @_;

  my $dashes = '-' x 75;
  $dashes .= "\n\n" if $self->{CFG}{double_spacing};

  $self->mailer->print(<<END);
Below is the result of your feedback form.  It was submitted by
$self->{FormConfig}{realname} ($self->{FormConfig}{email}) on $date
$dashes
END
}

sub send_main_email_print_config {
  my ($self) = @_;

  if ($self->{FormConfig}{print_config}) {
    foreach my $cfg (@{ $self->{FormConfig}{print_config} }) {
      if ($self->{FormConfig}{$cfg}) {
        $self->mailer->print("$cfg: $self->{FormConfig}{$cfg}\n");
	$self->mailer->print("\n") if $self->{CFG}{double_spacing};
      }
    }
  }
}

sub send_main_email_fields {
  my ($self) = @_;

  foreach my $f (@{ $self->{Field_Order} }) {
    my $val = (defined $self->{Form}{$f} ? $self->{Form}{$f} : '');

    $self->send_main_email_field($f, $val);
  }
}

sub send_main_email_field {
  my ($self, $name, $value) = @_;
  
  my ($prefix, $line) = $self->build_main_email_field($name, $value);

  my $nl = ($self->{CFG}{double_spacing} ? "\n\n" : "\n");

  if ($self->{CFG}{wrap_text} and length("$prefix$line") > $self->email_wrap_columns) {
    $self->mailer->print( $self->wrap_field_for_email($prefix, $line) . $nl );
  }
  else {
    $self->mailer->print("$prefix$line$nl");
  }
}

sub build_main_email_field {
  my ($self, $name, $value) = @_;

  return ("$name: ", $value);
}

sub wrap_field_for_email {
  my ($self, $prefix, $value) = @_;

  my $subs_indent = '';
  $subs_indent = ' ' x length($prefix) if $self->{CFG}{wrap_style} == 1;

  local $Text::Wrap::columns = $self->email_wrap_columns;

  # Some early versions of Text::Wrap will die on very long words, if that
  # happens we fall back to no wrapping.
  my $wrapped;
  eval { local $SIG{__DIE__} ; $wrapped = wrap($prefix,$subs_indent,$value) };
  return ($@ ? "$prefix$value" : $wrapped);
}

sub email_wrap_columns { 72; }

sub send_main_email_footer {
  my ($self) = @_;

  my $dashes = '-' x 75;
  $self->mailer->print("$dashes\n\n");

  foreach my $e (@{ $self->{FormConfig}{env_report}}) {
    if ($ENV{$e}) {
      $self->mailer->print("$e: " . $self->strip_nonprint($ENV{$e}) . "\n");
    }
  }
}

sub send_conf_email {
  my ($self, $date, $email, $realname) = @_;

  if ( $self->{CFG}{send_confirmation_mail} and $email =~ /\@/ ) {
    my $to = (length $realname ? "$email ($realname)" : $email);
    $self->mailer->newmail("NMS FormMail.pm v$VERSION", $self->{CFG}{postmaster}, $email);
    $self->mailer->print("To: $to\n$self->{CFG}{confirmation_text}");
    $self->mailer->endmail;
  }
}

sub success_page {
  my ($self, $date) = @_;

  if ($self->{FormConfig}{'redirect'}) {
    print $self->cgi_object->redirect( $self->{FormConfig}{'redirect'} );
  }
  else {
    $self->output_cgi_html_header;
    $self->success_page_html_preamble($date);
    $self->success_page_fields;
    $self->success_page_footer;
  }
}

sub success_page_html_preamble {
  my ($self, $date) = @_;

  my $title = $self->escape_html( $self->{FormConfig}{'title'} || 'Thank You' );
  my $torecipient = 'to ' . $self->escape_html($self->{FormConfig}{'recipient'});
  $torecipient = '' if $self->{Hide_Recipient};
  my $attr = $self->body_attributes;

    print <<END;
  <head>
     <title>$title</title>
END

    $self->output_style_element;

    print <<END;
     <style>
       h1.title {
                   text-align : center;
                }
     </style>
  </head>
  <body $attr>
    <h1 class="title">$title</h1>
    <p>Below is what you submitted $torecipient on $date</p>
    <p><hr size="1" width="75%" /></p>
END
}

sub success_page_fields {
  my ($self) = @_;

  foreach my $f (@{ $self->{Field_Order} }) {
    my $val = (defined $self->{Form}{$f} ? $self->{Form}{$f} : '');
    $self->success_page_field( $self->escape_html($f), $self->escape_html($val) );
  }
}

sub success_page_field {
  my ($self, $name, $value) = @_;

  print "<p><b>$name:</b> $value</p>\n";
}

sub success_page_footer {
  my ($self) = @_;

  print qq{<p><hr size="1" width="75%" /></p>\n};
  $self->success_page_return_link;
  print <<END;
        <hr size="1" width="75%" />
        <p align="center">
           <font size="-1">
             <a href="http://nms-cgi.sourceforge.net/">FormMail</a>
             &copy; 2001  London Perl Mongers
           </font>
        </p>
        </body>
       </html>
END
}

sub success_page_return_link {
  my ($self) = @_;

  if ($self->{FormConfig}{return_link_url} and $self->{FormConfig}{return_link_title}) {
    print "<ul>\n";
    print '<li><a href="', $self->escape_html($self->{FormConfig}{return_link_url}),
       '">', $self->escape_html($self->{FormConfig}{return_link_title}), "</a>\n";
    print "</li>\n</ul>\n";
  }
}

sub body_attributes {
  my ($self) = @_;

  my %attrs = (bgcolor     => 'bgcolor',
               background  => 'background',
               link_color  => 'link',
               vlink_color => 'vlink',
               alink_color => 'alink',
               text_color  => 'text');

  my $attr = '';

  foreach my $at (keys %attrs) {
    my $val = $self->{FormConfig}{$at};
    next unless $val;
    if ($at =~ /color$/) {
      $val = $self->validate_html_color($val);
    }
    elsif ($at eq 'background') {
      $val = $self->validate_url($val);
    }
    else {
      die "no check defined for body attribute [$at]";
    }
    $attr .= qq( $attrs{$at}=") . $self->escape_html($val) . '"' if $val;
  }

  return $attr;
}


sub error_page {
  my ($self, $title, $error_body) = @_;

  $self->output_cgi_html_header;

  my $etitle = $self->escape_html($title);
  print <<END;
  <head>
    <title>$etitle</title>
END


  print <<END;
    <style type="text/css">
    <!--
       body {
              background-color: #FFFFFF;
              color: #000000;
             }
       table {
               background-color: #9C9C9C;
             }
       p.c2 {
              font-size: 80%;
              text-align: center;
            }
       tr.title_row  {
                        background-color: #9C9C9C;
                      }
       tr.body_row   {
                         background-color: #CFCFCF;
                      }

       th.c1 {
               text-align: center;
               font-size: 143%;
             }
       p.c3 {font-size: 80%; text-align: center}
       div.c2 {margin-left: 2em}
     -->
    </style>
END

  $self->output_style_element;

print <<END;
  </head>
  <body>
    <table border="0" width="600" summary="">
      <tr class="title_row">
        <th class="c1">$etitle</th>
      </tr>
      <tr class="body_row">
        <td>
          $error_body
          <hr size="1" />
          <p class="c3">
            <a href="http://nms-cgi.sourceforge.net/">FormMail</a>
            &copy; 2001-2003 London Perl Mongers
          </p>
        </td>
      </tr>
    </table>
  </body>
</html>
END
}

sub mailer {
  my ($self) = @_;

  return $self->{Mailer};
}

1;


END_INLINED_CGI_NMS_Script_FormMail
  $INC{'CGI/NMS/Script/FormMail.pm'} = 1;
}

}
#
# End of inlined modules
#
use CGI::NMS::Script::FormMail;
use base qw(CGI::NMS::Script::FormMail);

use vars qw($script);
BEGIN {
  $script = __PACKAGE__->new(
     DEBUGGING              => $DEBUGGING,
     name_and_version       => 'NMS FormMail 3.12c1',
     emulate_matts_code     => $emulate_matts_code,
     secure                 => $secure,
     allow_empty_ref        => $allow_empty_ref,
     max_recipients         => $max_recipients,
     mailprog               => $mailprog,
     postmaster             => $postmaster,
     referers               => [@referers],
     allow_mail_to          => [@allow_mail_to],
     recipients             => [@recipients],
     recipient_alias        => {%recipient_alias},
     valid_ENV              => [@valid_ENV],
     charset                => $charset,
     date_fmt               => $date_fmt,
     style                  => $style,
     no_content             => $no_content,
     double_spacing         => $double_spacing,
     wrap_text              => $wrap_text,
     wrap_style             => $wrap_style,
     send_confirmation_mail => $send_confirmation_mail,
     confirmation_text      => $confirmation_text,
     %more_config
  );
}

$script->request;

=info
<form method="post" action = "/cgi-bin/FormMail.pl">
<label for="subject">subject</label>
<input name="subject" type="text"/>
<br/>
<label for="recipient">recipient</label>
<input name="recipient" type="text"/>
<br/>
<label for="email">email</label>
<input name="email" type="text"/>
<br/>
<label for="title">title</label>
<input name="title" type="text"/>
<br/>
<input text="submit" type="submit"/>
</form>
   subject this is suject______
   recipient recipient@gmail.com
   email sender@gmail.com____
   title title of the mail___
   Submit

  Error: Bad or Missing Recipient

   There was no recipient or an invalid recipient specified in the data
   sent to FormMail. Please make sure you have filled in the recipient
   form field with an e-mail address that has been configured in
   @recipients or @allow_mail_to. More information on filling in
   recipient/allow_mail_to form fields and variables can be found in the
   README file.
     __________________________________________________________________

   The recipient was: [ recipient@gmail.com ]
     __________________________________________________________________

   FormMail ¦ 2001-2003 London Perl Mongers
=cut
