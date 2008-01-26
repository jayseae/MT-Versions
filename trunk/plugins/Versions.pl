# ===========================================================================
# Copyright 2006, Everitz Consulting (mt@everitz.com)
# ===========================================================================
package MT::Plugin::Versions;

use base qw(MT::Plugin);
use strict;

use MT;

my $Versions;
my $about = {
  name => 'MT-Versions',
  description => 'Easily change the output of the MTVersion template tag.',
  author_name => 'Everitz Consulting',
  author_link => 'http://www.everitz.com/',
  version => '0.0.1',
  config => \&configure_plugin_settings,
  system_config_template => \&settings_template,
  settings => new MT::PluginSettings([
    ['version_control', { Default => 1 }],
    ['version_override']
  ])
};
$Versions = MT::Plugin::Versions->new($about);
MT->add_plugin($Versions);

{
  local $SIG{__WARN__} = sub {  }; 
  my $mt_vi = \&MT::version_id;
  *MT::version_id = sub {
    my $vc = $Versions->get_config_value('version_control');
    my $vo = $Versions->get_config_value('version_override');
    return $vo if ($vc == 2 && $vo);
    &$mt_vi;
  }; 
}

# plugin stuff

sub configure_plugin_settings {
  my $config = {};
  if ($Versions) {
    use MT::Request;
    my $r = MT::Request->instance;
    my ($scope) = (@_);
    $config = $r->cache('versions_config_'.$scope);
    if (!$config) {
      $config = $Versions->get_config_hash($scope);
      $r->cache('versions_config_'.$scope, $config);
    }
  }
  $config;
}

sub settings_template {
  my $tmpl = <<'EOT';
  <script language="JavaScript">
    <!--
      function hide_and_seek () {
        if (document.getElementById('version_control_2').checked) {
          document.getElementById('version_override').disabled = 0;
        } else {
          document.getElementById('version_override').disabled = 1;
        }
      }
    //-->
  </script>
  <div class="setting">
    <div class="field">
      <p>
        <br />
        <input type="radio" name="version_control" id="version_control_1" onclick="hide_and_seek()" value="1" <TMPL_IF NAME=VERSION_CONTROL_1>checked="checked"</TMPL_IF> /> Use Movable Type Version (Default)<br />
        <input type="radio" name="version_control" id="version_control_2" onclick="hide_and_seek()" value="2" <TMPL_IF NAME=VERSION_CONTROL_2>checked="checked"</TMPL_IF> /> Use this Version Number Instead:<br /><br />
        <input id="version_override" name="version_override" size="10" <TMPL_IF NAME=VERSION_OVERRIDE>value="<TMPL_VAR NAME=VERSION_OVERRIDE>"</TMPL_IF> />
      </p>
    </div>
  </div>
  <script language="JavaScript">
    <!--
      hide_and_seek();
    //-->
  </script>
EOT
}

1;