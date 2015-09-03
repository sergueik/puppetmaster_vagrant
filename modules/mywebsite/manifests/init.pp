# -*- mode: puppet -*-
# vi: set ft=puppet :
class mywebsite {
    iis::manage_app_pool {'my_application_pool':
      enable_32_bit           => true,
      managed_runtime_version => 'v4.0',
    }

    iis::manage_site {'www.mysite.com':
      site_path     => 'C:\inetpub\wwwroot\mysite',
      port          => '8080',
      ip_address    => '*',
      host_header   => 'www.mysite.com',
      app_pool      => 'my_application_pool'
    }

    iis::manage_virtual_application {'application1':
      site_name   => 'www.mysite.com',
      site_path   => 'C:\inetpub\wwwroot\application1',
      app_pool    => 'my_application_pool'
    }

    iis::manage_virtual_application {'application2':
      site_name   => 'www.mysite.com',
      site_path   => 'C:\inetpub\wwwroot\application2',
      app_pool    => 'my_application_pool'
    }
}

