import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  bool showWelcomeDialog = true;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then(
      (sharedPrefs) {
        setState(() {
          showWelcomeDialog = sharedPrefs.getBool(showWelcomeDialogKey) ?? true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const body = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            children: [
              TextSpan(
                text: """How to use this site:""",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "\n"),
              TextSpan(
                text:
                    """• Browse: There are more than 275 entries in this collection, with music and comments to keep you engaged for hours.""",
              ),
              TextSpan(text: "\n"),
              TextSpan(
                text:
                    """• Zoom by geography: As you zoom in, bands that have been grouped geographically show up as individual spots on the map. In musical hotspots such as Boston and Seattle, we've placed each band in a unique location.""",
              ),
              TextSpan(text: "\n"),
              TextSpan(
                text:
                    """• Zoom by chronology: Click on the three lines in the upper left corner of the screen and adjust the sliders. For instance, view albums released before 1975.""",
              ),
              TextSpan(text: "\n"),
              TextSpan(
                text:
                    """• Search: In that same menu, select a person or band name, or type the name. The timeline and map will display just those entries where they appear. Unclick the name or delete your search term to reset the map; if need be, refresh your screen.""",
              ),
              TextSpan(text: "\n"),
            ],
          ),
          TextSpan(text: "\n"),
          TextSpan(
            children: [
              TextSpan(
                text: """About this project:""",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "\n"),
              TextSpan(
                text:
                    """This site celebrates bands who played for contra or square dances in the early years of the dance revivals of the past half century. These musicians were among the first to play for such dances in a given community and who recorded.""",
              ),
            ],
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """For the most part, these are revival musicians, individuals who did not grow up in their particular music and dance tradition. The recordings start in the late 1960s and by design do not include bands from earlier decades, from Schroeder's Playboys in Phoenix to Don Messer in the Canadian Maritimes. That said, it's hard to draw a rigid line between traditional and revival; we have included Bob Holt, the Ozark square dance fiddler who also played for the nascent contra dance scene in St. Louis; Fletcher Bright, a long-time bluegrass fiddler who adapted to play for contras in Chattanooga, and Gerry Robichaud, who shared Maritime fiddle tunes with Boston dancers.""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """Although some are better known as concert bands, all the bands shown on this map played for dances. For example, Bertram Levy, the sole surviving member of the Hollow Rock String Band, confirmed that the band played for dances on the Duke University campus; others remembered Highwoods String Band at summer dances at Cornell.""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """From the outset, this project was interested in music played for two distinctive styles of American country dance. We mourn the mindset in some communities today that separates squares from contras; both forms deserve recognition. 
            
The “recording” criterion was included for two reasons:
  • It was an easy (and necessary) way to narrow the universe; attempting to document all bands who played for dances would be a vast undertaking. 
  • Part of the purpose of this project was to demonstrate the variety of music that has lifted dancers' feet over the decades. Audio examples provide more information than simply writing about different styles.""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """We sought commercial releases; a recording made by a band for internal listening would not suffice. Granted, some recordings were homemade, duplicated via double-deck cassette recorders for an impromptu merchandise table. However, we bent the rules to allow other recordings for a handful of bands. Such examples include live festival recordings (La Jolla Civic Country Dance Orchestra) or groups represented by a larger ensemble (Maine Country Dance Orchestra included in a live recording of The Mighty Cloud of Fiddlers.)""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """These are not the only dance bands. Numerous groups are remembered fondly though not represented here because they left no album. Indeed, there are many good reasons why only a small proportion of bands choose to enter a studio.""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """Don't jump to conclusions based on dates, either. Some musicians active in the 1970s did not record until 30 or 40 years later. There are also influential bands not included here simply because they came later in the history of a particular community.""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """From the outset, we wanted viewers to be able search both geographically—easy to do—and chronologically, a more challenging task. I'm a caller and dance historian, not a programmer, so the project stalled for a year while I sought someone to handle the technical challenges. A friend suggested Andrew Frock. His father is a caller, his mother a fiddler, and he he himself was a dancer and software developer. When he agreed to take on the programming, information moved from files on my computer to the website. Thank you, Andrew! We believe that this technique of combining geography and chronology can be useful to others, so Andrew is sharing this site's code on GitHub. Many music files here were contributed by musicians in the bands; others came from personal collections or from albums made available on YouTube and similar sites. If any group wishes their audio not to be included, or if we have incorrectly credited composers, misspelled names, or have incorrect information, please notify us and we will fix it. Finally, if others would like to add comments, or if you think another band meets the criteria for inclusion, please contact us.""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """Thanks to all the musicians who shared music files, scans of album covers, and, most of all, their memories. Thanks for going above and beyond go out to numerous individuals: Sue Songer provided composer names for the tunes; Scott Mathis provided audio files for many New Mexico bands; Everett Wren helped with Arkansas and Texas; Craig Johnson was a fount of information about San Francisco area bands; and James Hutson was a knowledgeable guide to southern California. In the early months, this project leaped ahead when Mac McKeever sent a flash drive full of audio files, album covers, and helpful information about St. Louis and Southern Illinois.""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text:
                """Here's to the many musicians who lifted dancers' feet in the last half century!""",
          ),
          TextSpan(text: "\n\n"),
          TextSpan(
            text: """David Millstone""",
          ),
        ],
      ),
      textAlign: TextAlign.justify,
    );

    return PointerInterceptor(
      child: SelectionArea(
        child: AlertDialog(
          title: Center(
            child: Text(
              "Welcome to A Hand for the Band!",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: const SingleChildScrollView(
              child: body,
            ),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: !showWelcomeDialog,
                  onChanged: (value) {
                    if (value != null) {
                      SharedPreferences.getInstance()
                          .then((sharedPrefs) =>
                              sharedPrefs.setBool(showWelcomeDialogKey, !value))
                          .then((_) {
                        setState(() {
                          showWelcomeDialog = !value;
                        });
                      });
                    }
                  },
                ),
                const Text("Don't show this again"),
              ],
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            )
          ],
        ),
      ),
    );
  }
}
