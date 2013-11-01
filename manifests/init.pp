class nginx_conf(
  $action = "install",) {

  if $action == 'install'{

    #add official nginx repo
    file {"create nginx repo":
      ensure	=> 	file,
      path	=>	"/etc/yum.repos.d/nginx.repo",
      source	=> 	"puppet:///modules/nginx_conf/nginx.repo",
    } 


    #install nginx package
    package {"install nginx":
      ensure 	=> 	latest,
      name	=>	"nginx",
      require	=>	File["create nginx repo"],
    }


    #update nginx.conf file to host over port 8081, and serve custom web content
    file {"nginx html config":
      ensure	=>	file,
      path	=>	"/etc/nginx/conf.d/default.conf",
      source	=>	"puppet:///modules/nginx_conf/default.conf",
      require	=>	Package["install nginx"],
    }


    #create new group for nginx user
    group {"nginx-user group add":
      ensure	=>	present,
      name	=>	"nginx-user",
      gid	=>	777,
    }


    #create new nginx user
    user {"nginx-user add":
      ensure	=>	present,
      name	=>	"nginx-user",
      uid	=>	777,
      gid	=>	777,
      shell	=>	"/bin/bash",
      home	=>	"/home/nginx-user",
    } 

    #create nginx default config, use our templated version
    file {"nginx default config":
      ensure	=>	file,
      path	=>	"/etc/nginx/nginx.conf",
      source	=>	"puppet:///modules/nginx_conf/nginx.conf",
      require	=>	Package["install nginx"],
    }

    #ensure the html root directory exists
    file {"html root dir":
      ensure	=> 	directory,
      path	=>	"/usr/share/nginx/html",
      owner	=>	"nginx-user",
      group	=>	"nginx-user",
    }

    #put our index.html file in place
    file {"html index file":
      ensure	=>	file,
      path	=>	"/usr/share/nginx/html/index.html",
      source	=>	"puppet:///modules/nginx_conf/index.html",
      owner	=>	"nginx-user",
      group	=>	"nginx-user",
    }

    #make sure the service is running and subscribed to any changes to the confifile
    service {"nginx":
      ensure	=> 	running,
      subscribe	=>	File["nginx default config"],
    }
  }
  else {

    #remove nginx user
    user {"nginx-user remove":
      ensure	=>	absent,
      name	=>	"nginx-user",
    } 

    #remove group for nginx user
    group {"nginx-user group remove":
      ensure	=>	absent,
      name	=>	"nginx-user",
    }

    #remove nginx package
    package {"remove nginx":
      ensure 	=> 	absent,
      name	=>	"nginx",
    }
    
    #remove the config dir
    file {"nginx default config remove":
      ensure	=>	absent,
      path	=>	"/etc/nginx/",
      recurse	=>	true,
      force	=>	true,
    }

    #remove the html root dir
    file {"html root dir remove":
      ensure	=> 	absent,
      path	=>	"/usr/share/nginx/html",
      recurse	=>	true,
      force	=>	true,
    }
  }
}

