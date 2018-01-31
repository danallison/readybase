(function () {
  // TODO make ReadyBase instantiable
  var readybase = window.readybase = {};
  var state = {};
  state.protocol = 'https';
  var toURL = function (path) {
    return state.protocol + '://' + state.domain + '/api/v1/' + path;
  };
  var toQueryString = function (obj) {
    return Object.keys(obj).map(function (key) {
      var val = typeof obj[key] === 'string' ? obj[key] : JSON.stringify(obj[key]);
      return key + '=' + encodeURIComponent(val);
    }).join('&');
  };
  var httpRequest = function (method, url, params) {
    return new Promise(function (resolve, reject) {
      var xhr = new XMLHttpRequest();
      xhr.withCredentials = true; // TODO check window.location
      if (method === 'get' && params) {
        url += '?' + toQueryString(params);
        params = null;
      }
      xhr.open(method, url, true);
      xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
      xhr.addEventListener('load', function (e) {
        var status = e.target.status;
        if (status === 200 || status === 201) {
          resolve(JSON.parse(e.target.response));
        } else if (status === 204) {
          resolve();
        } else {
          reject(e);
        }
      });
      if (params) {
        params = JSON.stringify(params);
        xhr.send(params);
      } else {
        xhr.send();
      }
    });
  };
  readybase.setProtocol = function (protocol) {
    state.protocol = protocol === 'http' ? 'http' : 'https';
    if (state.protocol === 'http') {
      if (window.location.hostname !== 'localhost') alert('A JavaScript agent has changed protocol to insecure HTTP for background requests. Your connection is not private, and there may be malicious code running on this webpage.');
      console.warn('WARNING: ReadyBase protocol was changed to insecure HTTP!\nHTTP should only be used in development.\nUsers will receive an alert in production.');
    }
  };
  readybase.setDomain = function (domain) {
    state.domain = domain;
  };
  ['get','post','put','delete'].forEach(function (method) {
    readybase[method] = function (path, params) {
      return httpRequest(method, toURL(path), params);
    };
  });
  readybase.signUp = function (email, password) {
    // var params =
    return readybase.post('users', {
      email: email,
      username: email,
      password: password,
    });
  };
  readybase.signIn = function (username, password) {
    return readybase.post('sessions', {
      username: username,
      password: password,
    });
  };
  readybase.signOut = function () {
    return readybase.delete('sessions');
  };
})();
