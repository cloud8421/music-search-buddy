window.addEventListener('load', function() {
  var attachFastClick = Origami.fastclick;
  attachFastClick(document.body);

  var app = Elm.Main.fullscreen();
});
