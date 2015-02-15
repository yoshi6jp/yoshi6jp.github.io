clock = new THREE.Clock
$webgl = $ '#webgl'
renderer = null
camera = null
effect = null
scene = null
controls = null
navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia
URL = window.URL || window.webkitURL
videoEle = $('#video').get 0
lCamEle = $('#leftcam').get 0
lCamCtx = lCamEle.getContext "2d"
rCamEle = $('#rightcam').get 0
rCamCtx = rCamEle.getContext "2d"
videoPlaying = false
model = null

fullscreen = ->
  return container.requestFullscreen()       if container.requestFullscreen
  return container.msRequestFullscreen()     if container.msRequestFullscreen
  return container.mozRequestFullScreen()    if container.mozRequestFullScreen
  return container.webkitRequestFullscreen() if container.webkitRequestFullscreen

setOrientationControls = (e)->
  return unless e.alpha

  controls = new THREE.DeviceOrientationControls camera, true
  controls.connect()
  controls.update()

  renderer.domElement.addEventListener 'click', fullscreen, false

  window.removeEventListener 'deviceorientation', setOrientationControls, true

initCam = ->
  MediaStreamTrack.getSources (data)->
    sourceId = null
    data.forEach (sourceInfo)->
      sourceId = sourceInfo.id if sourceInfo.kind == 'video'
    navigator.getUserMedia
      video:
        optional: [
          sourceId: sourceId
        ,
          minWidth: 640
        ,
          maxWidth: 640
        ,
          minHeight: 480
        ,
          maxHeight: 480
        ]
    , (stream)->
      videoEle.src = URL.createObjectURL stream
      videoEle.autoplay = true
      videoEle.play()
      setTimeout ->
        videoPlaying = true
      ,100
    , -> console.log "err=", arguments


initWebgl = ->
  renderer = new THREE.WebGLRenderer antialias: true, alpha: true
  renderer.setClearColor 0x000000, 0
  $webgl.append renderer.domElement
  effect = new THREE.StereoEffect renderer
  scene = new THREE.Scene

  camera = new THREE.PerspectiveCamera 90, 1, 0.001, 700
  camera.position.set 0, 150, 0
  scene.add camera

  controls = new THREE.OrbitControls camera, renderer.domElement
  controls.rotateUp Math.PI / 4
  controls.target.set camera.position.x + 0.1, camera.position.y, camera.position.z
  controls.noZoom = true
  controls.noPan = true

  window.addEventListener 'deviceorientation', setOrientationControls, true

  light = new THREE.HemisphereLight 0x777777, 0x000000, 0.6
  scene.add light

  light = new THREE.DirectionalLight 0xffffff, 2
  light.position.set(1, 1, 1).normalize()
  scene.add light

  grid = new THREE.GridHelper 1000,100
  # scene.add grid

  loader = new THREE.JSONLoader
  # loader.load 'objects/sofa.json', ( geometry, materials )->
  loader.load 'objects/Chair.json', ( geometry, materials )->
  # loader.load 'objects/alfaromeo.json', ( geometry, materials )->
    model = new THREE.Mesh geometry, new THREE.MeshFaceMaterial materials
    model.position.set 30,0,-150
    model.scale.set 100, 100, 100
    scene.add model

onceVibrate = _.once ->
  navigator.vibrate? [300, 300, 300]
init = ->
  do initCam
  do initWebgl
  peer = new Peer
    host:'peerjs-kamata.herokuapp.com'
    secure:true
    port:443
    key: 'peerjs'
    debug: 3
  id = location.hash.replace '#', ''
  if id
    conn = peer.connect id
    conn.on "data", (pos)->
      do onceVibrate
      model.position.set pos[0]*50, pos[1]*50, pos[2]*50


resize = ->
  width = $webgl.width()
  height = $webgl.height()

  camera.aspect = width / height
  camera.updateProjectionMatrix()

  renderer.setSize width, height
  effect.setSize width, height


render = ->
  effect.render scene, camera

update = (dt)->
  do resize
  do camera.updateProjectionMatrix
  controls.update dt

animate = ->
  requestAnimationFrame animate
  if videoPlaying
    lCamCtx.drawImage videoEle, 0, 0, videoEle.videoWidth, videoEle.videoHeight, 0, 0, lCamEle.width, lCamEle.height
    rCamCtx.drawImage videoEle, 0, 0, videoEle.videoWidth, videoEle.videoHeight, 0, 0, rCamEle.width, rCamEle.height
  update clock.getDelta()
  render()

do init
do animate
