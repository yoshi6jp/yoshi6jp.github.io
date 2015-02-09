console.log "ok"
activeConn = null
model = null
init = ->
  $room = $ "#room"
  renderer = new THREE.WebGLRenderer
  renderer.sortObjects = false
  renderer.setSize $room.width(), $room.height()
  $room.append renderer.domElement

  camera = new THREE.PerspectiveCamera 70, $room.width() / $room.height(), 1, 700
  camera.position.set 10, 5, 10
  camera.lookAt new THREE.Vector3 0, 2, 0

  scene = new THREE.Scene
  scene.add new THREE.GridHelper 10,1

  light = new THREE.DirectionalLight 0xffffff, 2
  light.position.set(1, 1, 1).normalize()
  scene.add light

  sendPos = _.throttle ->
    if activeConn
      activeConn.send [model.position.x, model.position.y, model.position.z]
  ,100

  render = ->
    renderer.render scene, camera
    do sendPos

  loader = new THREE.JSONLoader
  loader.load 'objects/Chair.json', ( geometry, materials )->
    model = new THREE.Mesh geometry, new THREE.MeshFaceMaterial materials
    control = new THREE.TransformControls camera, renderer.domElement
    control.addEventListener 'change', render

    scene.add model

    control.attach model
    scene.add control
    render()


  peer = new Peer
    host:'peerjs-kamata.herokuapp.com'
    secure:true
    port:443
    key: 'peerjs'
    debug: 3
  peer.on 'open', (id)->
    console.log "#{location.origin}/cardboard.html##{id}"
    new QRCode document.getElementById("qrcode"),"#{location.origin}/cardboard.html##{id}"

  peer.on "connection", (conn)->
    activeConn = conn

do init
