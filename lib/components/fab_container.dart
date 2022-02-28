import 'dart:io';

import 'package:Para/stories/stories.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_creator/story_creator.dart';
import '../posts/create_post.dart';

class FabContainer extends StatelessWidget {
  final Widget page;
  final IconData icon;
  final bool mini;
  File editedFile;

  FabContainer({@required this.page, @required this.icon, this.mini = false});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      openColor: Colors.black,
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return page;
      },
      closedElevation: 4.0,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(56 / 2),
        ),
      ),
      closedColor: Colors.black,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(
            icon,
            color: Colors.white,
          ),
          onPressed: () {
            chooseUpload(context);
          },
          mini: mini,
        );
      },
    );
  }

  chooseUpload(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Text(
                    'Créer une publication',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  CupertinoIcons.camera_on_rectangle,
                  size: 25.0,
                ),
                title: Text('Faire une publication'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => CreatePost(),
                    ),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  CupertinoIcons.add_circled,
                  size: 25.0,
                ),
                title: Text('Mettre une story'),
                onTap: () async {
                  final picker = ImagePicker();
                  await picker
                      .pickImage(source: ImageSource.gallery)
                      .then((file) async {
                    editedFile = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StoryCreator(
                          filePath: file.path,
                        ),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
