import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:ditpolairud_petugas/settings/agora.dart' as config;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:http/http.dart' as http;

/// MultiChannel Example
class JoinChannelVideo extends StatefulWidget {
  final int call_status;
  final token;
  JoinChannelVideo(this.call_status, this.token);
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<JoinChannelVideo> {
  RtcEngine _engine;
  String channelId = config.channelId;
  bool isJoined = false, switchCamera = true, switchRender = false;
  // int remoteUid = 0;
  List<int> remoteUid = [];
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: channelId);
    this._initEngine();
    ring();
    _callStatus();
  }

  @override
  void dispose() {
    super.dispose();
    _engine.destroy();
  }

  _initEngine() async {
    _engine = await RtcEngine.createWithConfig(RtcEngineConfig(config.appId));
    this._addListeners();
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
  }

  _addListeners() {
    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        log('joinChannelSuccess ${channel} ${uid} ${elapsed}');
        setState(() {
          isJoined = true;
        });
      },
      userJoined: (uid, elapsed) {
        log('userJoined  ${uid} ${elapsed}');
        setState(() {
          remoteUid.add(uid);
          // remoteUid = uid;
        });
      },
      userOffline: (uid, reason) {
        log('userOffline  ${uid} ${reason}');
        setState(() {
          remoteUid.removeWhere((element) => element == uid);
          // remoteUid = 0;
        });
      },
      leaveChannel: (stats) {
        log('leaveChannel ${stats.toJson()}');
        setState(() {
          isJoined = false;
          remoteUid.clear();
        });
      },
    ));
  }

  bool openMicrophone = true;
  bool openVideo = true;

  _switchMicrophone() {
    _engine.enableLocalAudio(!openMicrophone).then((value) {
      setState(() {
        openMicrophone = !openMicrophone;
      });
    }).catchError((err) {
      log('enableLocalAudio $err');
    });
  }

  _switchVideo() async {
    _engine.enableLocalVideo(!openVideo).then((value) async {
      if (openVideo == true) {
        await _engine.disableVideo();
        setState(() {
          openVideo = !openVideo;
        });
      } else {
        await _engine.enableVideo();
        setState(() {
          openVideo = !openVideo;
        });
      }
    }).catchError((err) {
      log('enableLocalAudio $err');
    });
  }

  _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine.joinChannel(
        widget.token, widget.call_status.toString(), null, 1);
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    Navigator.pop(context, "Done");
  }

  _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      log('switchCamera $err');
    });
  }

  _switchRender() {
    setState(() {
      switchRender = !switchRender;
      remoteUid = List.of(remoteUid.reversed);
      // remoteUid = 0;
    });
  }

  int call_status = 0;
  Future<List> _callStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/call-status");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _call_status;

    _call_status = json.decode(response.body);
    setState(() {
      call_status = _call_status['user']['call_status'];
      if (call_status == 0) {
        Navigator.pop(context, "Done");
      }
    });
    if (call_status != 0) {
      Future.delayed(Duration(seconds: 2), () {
        _callStatus();
      });
    }
  }

  bool ringing = false;
  ring() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('statusPush', '0');
    setState(() {
      ringing = !ringing;
    });
    Future.delayed(Duration(seconds: 3), () {
      ring();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('statusPush', '0');
          // Navigator.pop(context, "Done");
          return true;
        },
        child: Stack(
          children: [
            isJoined
                ? Column(
                    children: [
                      _renderVideo(),
                    ],
                  )
                : Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                      color: ringing
                          ? Colors.blueGrey.withOpacity(0.7)
                          : Colors.blueGrey,
                      child: Center(
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
            Positioned(
              left: 30,
              right: 30,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isJoined
                      ? GestureDetector(
                          onTap: this._switchVideo,
                          child: AnimatedContainer(
                            height: 50,
                            width: 50,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.linear,
                            decoration: BoxDecoration(
                                color: openVideo
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.white,
                                shape: BoxShape.circle),
                            child: Center(
                              child: openVideo
                                  ? Icon(
                                      Icons.videocam_off_outlined,
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      Icons.videocam_off_outlined,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        )
                      : Container(),
                  GestureDetector(
                    onTap: isJoined ? this._leaveChannel : this._joinChannel,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: isJoined ? Colors.red : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isJoined
                            ? Icon(
                                Icons.call_end,
                                color: Colors.white,
                              )
                            : Icon(Icons.call, color: Colors.white),
                      ),
                    ),
                  ),
                  isJoined
                      ? GestureDetector(
                          onTap: this._switchMicrophone,
                          child: AnimatedContainer(
                            height: 50,
                            width: 50,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.linear,
                            decoration: BoxDecoration(
                                color: openMicrophone
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.white,
                                shape: BoxShape.circle),
                            child: Center(
                              child: openMicrophone
                                  ? Icon(
                                      Icons.mic_off_outlined,
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      Icons.mic_off_outlined,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: this._switchCamera,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Icon(
                      Icons.flip_camera_ios_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _renderVideo() {
    return Expanded(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child:
                // Row(
                //   children: [
                //     GestureDetector(
                //       onTap: this._switchRender,
                //       child: Container(
                //         color: Colors.black,
                //         height: MediaQuery.of(context).size.height,
                //         width: MediaQuery.of(context).size.width,
                //         child: Center(
                //           child: RtcRemoteView.SurfaceView(
                //             uid: 0,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                Row(
              children: List.of(remoteUid.map(
                (e) => GestureDetector(
                  onTap: this._switchRender,
                  child: Container(
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: RtcRemoteView.SurfaceView(
                        uid: e,
                      ),
                    ),
                  ),
                ),
              )),
            ),
          ),
          Positioned(
            left: 10,
            top: 50,
            child: Container(
                width: 120, height: 120, child: RtcLocalView.SurfaceView()),
          )
        ],
      ),
    );
  }

//OLD STUFF
  // _renderVideo() {
  //   return Expanded(
  //     child: Stack(
  //       children: [
  //         RtcLocalView.SurfaceView(),
  //         Positioned(
  //           right: 10,
  //           top: 50,
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: Row(
  //               children: List.of(remoteUid.map(
  //                 (e) => GestureDetector(
  //                   onTap: this._switchRender,
  //                   child: Container(
  //                     width: 120,
  //                     height: 120,
  //                     child: RtcRemoteView.SurfaceView(
  //                       uid: e,
  //                     ),
  //                   ),
  //                 ),
  //               )),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}
