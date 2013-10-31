class nginx_conf {

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
  file {"nginx default config":
    ensure	=>	file,
    path	=>	"/etc/nginx/conf.d/default.conf",
    source	=>	"puppet:///modules/nginx_conf/default.conf",
  }


  #create new group for nginx user
  group {"nginx-user":
    ensure	=>	present,
    name	=>	"nginx-user",
    gid		=>	777,
  }


  #create new nginx user
  user {"nginx-user":
    name	=>	"nginx-user",
    uid		=>	777,
    gid		=>	777,
    shell	=>	"/bin/bash",
    home	=>	"/home/nginx-user",
  }


  #restart the service when the nginx.conf file changes
  service {"nginx":
    ensure 	=>	running,
    subscribe	=>	File["nginx default config"],
  }
}
