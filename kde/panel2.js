// drugi monitor: panel z zadaniami tylko z tego ekranu i zegarem
if (screenCount > 1) {
  var p = null;
  panels().forEach(function(x){ if (x.screen == 1) p = x; });
  if (!p) {
    p = new Panel("org.kde.panel");
    p.screen = 1;
  }
  if (p.widgets().length == 0) {
    p.addWidget("org.kde.plasma.icontasks");
    p.addWidget("org.kde.plasma.marginsseparator");
    p.addWidget("org.kde.plasma.digitalclock");
  }
  p.location = "bottom"; p.floating = false; p.lengthMode = "fill"; p.height = 40;
  panels().forEach(function(x){
    x.widgets("org.kde.plasma.icontasks").forEach(function(w){
      w.currentConfigGroup = ["General"];
      w.writeConfig("showOnlyCurrentScreen", true);
    });
  });
  print("panel na ekranie 1: id " + p.id);
} else { print("jeden monitor, pomijam"); }
