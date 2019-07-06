function ClearAuthentication(LogOffPage)
{
  var IsInternetExplorer = false;

  try {
      var agt=navigator.userAgent.toLowerCase();
      if (agt.indexOf("msie") != -1) { IsInternetExplorer = true; }
  }
  catch(e) {
      IsInternetExplorer = false;
  };

  if (IsInternetExplorer) {
     // Logoff Internet Explorer
     document.execCommand("ClearAuthenticationCache");
     window.location = LogOffPage;
  }
  else {
     // Logoff every other browsers
    $.ajax({
      username: 'unknown',
      password: 'WrongPassword',
      url: './cgi-bin/PrimoCgi',
      type: 'GET',
      beforeSend: function(xhr) {
         xhr.setRequestHeader("Authorization", "Basic AAAAAAAAAAAAAAAAAAA=");
      },
      error: function(err) {
         window.location = LogOffPage;
      }
    });
  }
}

$(document).ready(function () {
  $('#Btn1').click(function() {
     // Call Clear Authentication
     ClearAuthentication("force_logout.html");
  });
});
