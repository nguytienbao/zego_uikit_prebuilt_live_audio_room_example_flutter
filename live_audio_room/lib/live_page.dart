// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

// Project imports:
import 'constants.dart';
import 'media.dart';

class LivePage extends StatefulWidget {
  final String roomID;
  final bool isHost;
  final LayoutMode layoutMode;

  const LivePage({
    Key? key,
    required this.roomID,
    this.layoutMode = LayoutMode.horizontal,
    this.isHost = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LivePageState();
}

class LivePageState extends State<LivePage> {
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltLiveAudioRoom(
      appID: 1985552479 /*input your AppID*/,
      appSign:
          'fcdacabe18cfa300b2b5dbef4ed31f4a9608cebd7d6b651971a1c09400ca8d4e' /*input your AppSign*/,
      userID: localUserID,
      userName: 'user_$localUserID',
      roomID: widget.roomID,
      events: events,
      config: config,
    );
  }

  ZegoUIKitPrebuiltLiveAudioRoomConfig get config {
    return (widget.isHost
        ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
        : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience())
      ..duration = ZegoLiveAudioRoomLiveDurationConfig(isVisible: false)
      ..seat = (getSeatConfig()
        ..takeIndexWhenJoining = widget.isHost ? getHostSeatIndex() : -1
        ..hostIndexes = getLockSeatIndex()
        ..layout = getLayoutConfig())
      ..background = background()
      ..foreground = foreground()
      ..inRoomMessage = ZegoLiveAudioRoomInRoomMessageConfig(visible: false)
      ..userAvatarUrl = 'https://robohash.org/$localUserID.png'
      
      ..bottomMenuBar = ZegoLiveAudioRoomBottomMenuBarConfig(
        maxCount: 3,
        hostButtons: [
          ZegoLiveAudioRoomMenuBarButtonName.toggleMicrophoneButton,
          ZegoLiveAudioRoomMenuBarButtonName.showMemberListButton,
        ],
        speakerButtons: [
          ZegoLiveAudioRoomMenuBarButtonName.toggleMicrophoneButton,
          ZegoLiveAudioRoomMenuBarButtonName.applyToTakeSeatButton,
        ],
      );
  }

  ZegoUIKitPrebuiltLiveAudioRoomEvents get events {
    return ZegoUIKitPrebuiltLiveAudioRoomEvents(
      user: ZegoLiveAudioRoomUserEvents(
        onCountOrPropertyChanged: (List<ZegoUIKitUser> users) {
          debugPrint(
            'onUserCountOrPropertyChanged:${users.map((e) => e.toString())}',
          );
        },
      ),
      seat: ZegoLiveAudioRoomSeatEvents(
        onClosed: () {
          debugPrint('on seat closed');
        },
        onOpened: () {
          debugPrint('on seat opened');
        },
        onChanged: (
          Map<int, ZegoUIKitUser> takenSeats,
          List<int> untakenSeats,
        ) {
          debugPrint(
            'on seats changed, taken seats:$takenSeats, untaken seats:$untakenSeats',
          );
        },

        /// WARNING: will override prebuilt logic
        // onClicked:(int index, ZegoUIKitUser? user) {
        //   debugPrint(
        //       'on seat clicked, index:$index, user:${user.toString()}');
        // },
        host: ZegoLiveAudioRoomSeatHostEvents(
          onTakingRequested: (ZegoUIKitUser audience) {
            debugPrint('on seat taking requested, audience:$audience');
          },
          onTakingRequestCanceled: (ZegoUIKitUser audience) {
            debugPrint('on seat taking request canceled, audience:$audience');
          },
          onTakingInvitationFailed: () {
            debugPrint('on invite audience to take seat failed');
          },
          onTakingInvitationRejected: (ZegoUIKitUser audience) {
            debugPrint('on seat taking invite rejected');
          },
        ),
        audience: ZegoLiveAudioRoomSeatAudienceEvents(
          onTakingRequestFailed: () {
            debugPrint('on seat taking request failed');
          },
          onTakingRequestRejected: () {
            debugPrint('on seat taking request rejected');
          },
          onTakingInvitationReceived: () {
            debugPrint('on host seat taking invite sent');
          },
        ),
      ),

      /// WARNING: will override prebuilt logic
      memberList: ZegoLiveAudioRoomMemberListEvents(
        onMoreButtonPressed: onMemberListMoreButtonPressed,
      ),
    );
  }

  Widget foreground() {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Stack(
        
        children: [
          Container(
            margin: EdgeInsets.only(bottom: kBottomNavigationBarHeight,),
            height: MediaQuery.of(context).size.height * .7, color: Colors.blueAccent,),
          Positioned(
            bottom: kBottomNavigationBarHeight,
            child: StreamBuilder<List<ZegoInRoomMessage>>(
              stream: ZegoUIKitPrebuiltLiveAudioRoomController().message.stream(),
              builder: (context, snapshot) {
                final messages = (snapshot.data ?? <ZegoInRoomMessage>[]).reversed.toList();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  width: MediaQuery.of(context).size.width,
                  constraints: const BoxConstraints(maxHeight: 160),
                  decoration: const BoxDecoration(color: Colors.black26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.arrow_drop_down,
                              size: 30,
                              color: Colors.white,
                            ),
                          )),
                      Flexible(
                        child: ListView.separated(
                          padding: EdgeInsets.only(bottom: 15),
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 17,
                                  foregroundImage: NetworkImage(
                                      'https://res.cloudinary.com/dsqpl191o/image/upload/public/645/33b/4dc/64533b4dca2ee309819173.jpg'),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            message.user.name,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Icon(
                                            Icons.android,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        message.message,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: 10,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget background() {
    /// how to replace background view
    return Stack(
      children: [
        
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [.1, .5],
                  colors: [Color(0xff30295D), Color(0xff14131A)])),
        ),
        Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Colors.white.withOpacity(.05)),),
        Container(
          height: kToolbarHeight+ MediaQuery.of(context).viewPadding.top,
width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            
            image: DecorationImage(opacity: .5, fit: BoxFit.cover,image: NetworkImage('https://sudokuplus.h5games.usercontent.goog/v/40a906fb-b228-42d0-8f9e-2a044bc9b19e/high_res_banner.jpg')),
              ),
        ),
        Positioned(
            top: MediaQuery.of(context).viewPadding.top + 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Game ${widget.roomID}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
        Positioned(
          top: MediaQuery.of(context).viewPadding.top + 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                    bottomLeft: Radius.circular(6)),
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xff2181C7), Color(0xff5F3AF6)])),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('1.01k',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    )),
                const SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.remove_red_eye,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).viewPadding.top + 10,
          right: 10,
          child: GestureDetector(
            onTap: () =>
                ZegoUIKitPrebuiltLiveAudioRoomController().leave(context),
            child: Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                    color: Colors.white54, shape: BoxShape.circle),
                child: const Center(
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white,
                  ),
                )),
          ),
        )
      ],
    );
  }

// await ZegoUIKit().leaveRoom();
  ZegoLiveAudioRoomSeatConfig getSeatConfig() {
    // if (widget.layoutMode == LayoutMode.horizontal) {
    // return ZegoLiveAudioRoomSeatConfig(
    //   avatarBuilder: (context, size, user, extraInfo) {
    //     return Container(color: Colors.green, height: 30, width: 30,);
    //   },
    //   foregroundBuilder: (context, size, user, extraInfo) {
    //     return Container(color: Colors.transparent, height: 30, width: 30,);
    //   },
    //   backgroundBuilder: (
    //     BuildContext context,
    //     Size size,
    //     ZegoUIKitUser? user,
    //     Map<String, dynamic> extraInfo,
    //   ) {
    //     return Container(color: Colors.transparent, height: 30, width: 30,);
    //   },
    // );
    return ZegoLiveAudioRoomSeatConfig(
      // openIcon: Image.network('https://res.cloudinary.com/dsqpl191o/image/upload/public/645/33b/4dc/64533b4dca2ee309819173.jpg'),
      closeWhenJoining: false,
        avatarBuilder: avatarBuilder,
        // backgroundBuilder: (context, size, user, extraInfo) {
        //   return SizedBox(height: 30, width: 30,);
        // },
        );
  }

  Widget avatarBuilder(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    return CircleAvatar(
      maxRadius: size.width,
      backgroundImage: Image.asset(
              "assets/avatars/avatar_${((int.tryParse(user?.id ?? "") ?? 0) % 6)}.png")
          .image,
    );
  }

  int getHostSeatIndex() {
    if (widget.layoutMode == LayoutMode.hostCenter) {
      return 4;
    }

    return 0;
  }

  List<int> getLockSeatIndex() {
    if (widget.layoutMode == LayoutMode.hostCenter) {
      return [4];
    }

    return [0];
  }

  ZegoLiveAudioRoomLayoutConfig getLayoutConfig() {
    final config = ZegoLiveAudioRoomLayoutConfig();
    config.rowSpacing = 0;
    config.rowConfigs = [
      ZegoLiveAudioRoomLayoutRowConfig(
        count: 5,
        alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround,
      ),
    ];

    return config;
  }

  void onMemberListMoreButtonPressed(ZegoUIKitUser user) {
    showModalBottomSheet(
      backgroundColor: const Color(0xff111014),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      isDismissible: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        const textStyle = TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
        final listMenu = ZegoUIKitPrebuiltLiveAudioRoomController()
                .seat
                .localHasHostPermissions
            ? [
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();

                    ZegoUIKit().removeUserFromRoom(
                      [user.id],
                    ).then((result) {
                      debugPrint('kick out result:$result');
                    });
                  },
                  child: Text(
                    'Kick Out ${user.name}',
                    style: textStyle,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();

                    ZegoUIKitPrebuiltLiveAudioRoomController()
                        .seat
                        .host
                        .inviteToTake(user.id)
                        .then((result) {
                      debugPrint('invite audience to take seat result:$result');
                    });
                  },
                  child: Text(
                    'Invite ${user.name} to take seat',
                    style: textStyle,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: textStyle,
                  ),
                ),
              ]
            : [];
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: listMenu.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 30,
                  child: Center(child: listMenu[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
