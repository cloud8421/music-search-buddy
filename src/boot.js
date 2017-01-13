window.addEventListener('load', function() {
  var app = Elm.Main.fullscreen();
});

if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    navigator.serviceWorker.register('/sw.js').then(function(registration) {
      // Registration was successful
      console.debug('ServiceWorker registration successful with scope: ', registration.scope);
    }).catch(function(err) {
      // registration failed :(
      console.debug('ServiceWorker registration failed: ', err);
    });
  });
}
