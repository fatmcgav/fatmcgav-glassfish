
class glassfish::download {
  define download_file(
          $site="",
          $cwd="",
          $creates="",
          $require="",
          $user="") {                                                                                         
  
      exec { $name:                                                                                                                     
          command => "/usr/bin/wget ${site}/${name}",                                                         
          cwd => $cwd,
          creates => "${cwd}/${name}",                                                              
          require => $require,
          user => $user,                                                                                                          
      }
  }
}