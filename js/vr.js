// Generated by CoffeeScript 1.7.1
(function() {
  var activeConn, init, model, object_id;

  object_id = location.hash.replace('#', '');

  activeConn = null;

  model = null;

  init = function() {
    var $room, camera, light, loader, peer, render, renderer, scene, sendPos;
    $room = $("#room");
    renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true
    });
    renderer.sortObjects = false;
    renderer.setSize($room.width(), $room.height());
    $room.append(renderer.domElement);
    camera = new THREE.PerspectiveCamera(70, $room.width() / $room.height(), 1, 700);
    camera.position.set(10, 5, 10);
    camera.lookAt(new THREE.Vector3(0, 2, 0));
    scene = new THREE.Scene;
    scene.add(new THREE.GridHelper(10, 1));
    light = new THREE.DirectionalLight(0xffffff, 2);
    light.position.set(1, 1, 1).normalize();
    scene.add(light);
    sendPos = _.throttle(function() {
      if (activeConn) {
        return activeConn.send([model.position.x, model.position.y, model.position.z]);
      }
    }, 100);
    render = function() {
      renderer.render(scene, camera);
      return sendPos();
    };
    loader = new THREE.JSONLoader;
    loader.load("objects/" + object_id + ".json", function(geometry, materials) {
      var control;
      model = new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials));
      control = new THREE.TransformControls(camera, renderer.domElement);
      control.addEventListener('change', render);
      model.scale.set(5, 5, 5);
      scene.add(model);
      control.attach(model);
      scene.add(control);
      return render();
    });
    peer = new Peer({
      host: 'peerjs-kamata.herokuapp.com',
      secure: true,
      port: 443,
      key: 'peerjs',
      debug: 3
    });
    peer.on('open', function(id) {
      console.log("" + location.origin + "/cardboard.html#" + id + "/" + object_id);
      return new QRCode(document.getElementById("qrcode"), "" + location.origin + "/cardboard.html#" + id + "/" + object_id);
    });
    return peer.on("connection", function(conn) {
      return activeConn = conn;
    });
  };

  init();

}).call(this);

//# sourceMappingURL=vr.map
