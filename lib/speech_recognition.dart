// import 'package:flutter/material.dart';
// import 'package:speech_recognition/speech_recognition.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'dart:async';

// enum TtsState { playing, stopped }

// enum VoiceStep { tracktype, category, amount, description, date, done }

// class SpeechRecognitionPage extends StatefulWidget {

//   @override
//   SpeechRecognitionPageState createState() => SpeechRecognitionPageState();
// }

// class SpeechRecognitionPageState extends State<SpeechRecognitionPage> {

//   // Speech to Text

//   SpeechRecognition _speechRecognition;
//   bool _isAvailable = false;
//   bool _isListening = false;
//   String resultText = "";

//   initSpeechRecognition() {
//     _speechRecognition = SpeechRecognition();
//     _speechRecognition.setAvailabilityHandler((bool result) => setState(() => _isAvailable = result));
//     _speechRecognition.setRecognitionStartedHandler(() => setState(() => _isListening = true));
//     _speechRecognition.setRecognitionResultHandler((String text) {
//       voiceResult(text);
//     });
//     _speechRecognition.setRecognitionCompleteHandler(() => setState(() => _isListening = false));
//     _speechRecognition
//     .activate()
//     .then((res) => setState(() => _isAvailable = res));
//   }

//   // Text to Voice

//   FlutterTts flutterTts;
//   List<dynamic> languages;

//   String _newVoiceText;

//   TtsState ttsState = TtsState.stopped;

//   get isPlaying => ttsState == TtsState.playing;
//   get isStopped => ttsState == TtsState.stopped;

//   initTts() async {
//     flutterTts = new FlutterTts();

//     flutterTts.setStartHandler(() {
//       setState(() {
//         ttsState = TtsState.playing;
//       });
//     });

//     flutterTts.setCompletionHandler(() {
//       setState(() {
//         ttsState = TtsState.stopped;
//       });
//       onMicPressed();
//     });

//     flutterTts.setErrorHandler((msg) {
//       setState(() {
//         ttsState = TtsState.stopped;
//       });
//     });

//     languages = await flutterTts.getLanguages;
//     if (languages != null) setState(() => languages);

//     setLanguage("en_IN");
//   }

//   Future _speak() async {
//     var result = await flutterTts.speak(_newVoiceText);
//     if (result == 1) setState(() => ttsState = TtsState.playing);
//   }

//   Future _stop() async {
//     var result = await flutterTts.stop();
//     if (result == 1) setState(() => ttsState = TtsState.stopped);
//   }

//   String language;

//   List<DropdownMenuItem<String>> getDropDownMenuItems() {
//     List<DropdownMenuItem<String>> items = new List();
//     for (String type in languages) {
//       items.add(new DropdownMenuItem(value: type, child: new Text(type)));
//     }
//     return items;
//   }

//   void changedDropDownItem(String selectedType) {
//     setState(() {
//       language = selectedType;
//       flutterTts.setLanguage(language);
//     });
//   }

//   void _onChange(String text) {
//     setState(() {
//       _newVoiceText = text;
//     });
//   }

//   // 

//   VoiceStep voiceStep = VoiceStep.tracktype;

//   void startCoversation() {
//     String askQuestion;
//     if(voiceStep == VoiceStep.tracktype) {
//       askQuestion = "Could you please tell me which type of track you want to add Income, Expense, Budget";
//     }
//     else if(voiceStep == VoiceStep.category) {
//         askQuestion = "Could you please tell me the category";
//     }
//     else if(voiceStep == VoiceStep.amount) {
//        askQuestion = "Could you please tell me the amount";
//     }
//     else if(voiceStep == VoiceStep.description) {
//         askQuestion = "Could you please tell me the description";
//     }
//     else if(voiceStep == VoiceStep.date) {
//       askQuestion = "Could you please tell me the date";
//     }
//     else if(voiceStep == VoiceStep.done) {
//       askQuestion = "Thank you for your inputs";
//     }
  
//     _speakText(askQuestion);

//   }

//   void voiceResult(String text) {
//       setState(() => resultText += text);
//       if(voiceStep == VoiceStep.tracktype) {
//         if(text.toUpperCase() == "INCOME" || text.toUpperCase() == "EXPENSE" || text.toUpperCase() == "BUDGET") {
//             setState(() => voiceStep = VoiceStep.category);
//             startCoversation();
//         }
//         else {
//           setState(() => voiceStep = VoiceStep.tracktype);
//           _speakText("Wrong Input");
//           startCoversation();
//         }
//       }
//       else if(voiceStep == VoiceStep.category) {
//         setState(() => voiceStep = VoiceStep.amount);
//         startCoversation();
//       }
//       else if(voiceStep == VoiceStep.amount) {
//         setState(() => voiceStep = VoiceStep.description);
//         startCoversation();
//       }
//       else if(voiceStep == VoiceStep.description) {
//         setState(() => voiceStep = VoiceStep.date);
//         startCoversation();
//       }
//       else if(voiceStep == VoiceStep.date) {
//         setState(() => voiceStep = VoiceStep.done);
//         startCoversation();
//       }
//   }

//   Future _speakText(String text) async {
//     var result = await flutterTts.speak(text);
//     if (result == 1) setState(() => ttsState = TtsState.playing);
//   }


//   void setLanguage(String lang) {
//     setState(() {
//       language = lang;
//       flutterTts.setLanguage(language);
//     });
//   }



//   @override
//   void initState() {
//     super.initState(); 
//     initSpeechRecognition();
//     initTts();
//     startCoversation();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     flutterTts.stop();
//     _speechRecognition.stop();
//   }

//   @override
//   Widget build(BuildContext context) {
//       return Scaffold(
//         appBar: AppBar(title: Text("Voice To Text"),),
//         body: Center(child: Text(resultText),) 

//         // languages != null
//         //       ? _buildRowWithLanguages()
//         //       : _buildRowWithoutLanguages()

//         // Column(
//         //   mainAxisAlignment: MainAxisAlignment.center,
//         //   crossAxisAlignment: CrossAxisAlignment.center,
//         //   children: <Widget>[
//         //     Row(children: <Widget>[
//         //     ],),
//         //     Row(
//         //       mainAxisAlignment: MainAxisAlignment.center,
//         //       children: <Widget>[
//         //         FloatingActionButton(
//         //           heroTag: "cancel",
//         //           child: Icon(Icons.cancel),
//         //           mini: true,
//         //           backgroundColor: Colors.deepOrange,
//         //           onPressed: onCancelPressed,
//         //         ),
//         //         FloatingActionButton(
//         //           heroTag: "mic",
//         //           child: Icon(Icons.mic),
//         //           backgroundColor: Colors.pink,
//         //           onPressed: onMicPressed,
//         //         ),
//         //         FloatingActionButton(
//         //           heroTag: "stop",
//         //           child: Icon(Icons.stop),
//         //           mini: true,
//         //           backgroundColor: Colors.deepPurple,
//         //           onPressed: onStopPressed,
//         //         )
//         //       ],
//         //     ),
//         //     Container(
//         //       width: MediaQuery.of(context).size.width * 0.6,
//         //       decoration: BoxDecoration(
//         //         color: Colors.cyanAccent[100],
//         //       ),
//         //       padding: EdgeInsets.symmetric(
//         //         vertical: 8.0,
//         //         horizontal: 12.0
//         //       ),
//         //       child: Text(resultText),
//         //     )
//         //   ],
//         // ),
//       );
//   }

//   Widget _buildRowWithoutLanguages() => Column(children: <Widget>[
//         Container(
//             alignment: Alignment.topCenter,
//             padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
//             child: TextField(
//               onChanged: (String value) {
//                 _onChange(value);
//               },
//             )),
//         Container(
//             padding: EdgeInsets.only(top: 200.0),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   IconButton(
//                       icon: Icon(Icons.play_arrow),
//                       onPressed: _newVoiceText == null || isPlaying
//                           ? null
//                           : () => _speak(),
//                       color: Colors.green,
//                       splashColor: Colors.greenAccent),
//                   IconButton(
//                       icon: Icon(Icons.stop),
//                       onPressed: isStopped ? null : () => _stop(),
//                       color: Colors.red,
//                       splashColor: Colors.redAccent),
//                 ]))
//       ]);

//   Widget _buildRowWithLanguages() => Column(children: <Widget>[
//         Container(
//             alignment: Alignment.topCenter,
//             padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
//             child: TextField(
//               onChanged: (String value) {
//                 _onChange(value);
//               },
//             )),
//         Container(
//             padding: EdgeInsets.only(top: 200.0),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   IconButton(
//                       icon: Icon(Icons.play_arrow),
//                       onPressed: _newVoiceText == null || isPlaying
//                           ? null
//                           : () => _speak(),
//                       color: Colors.green,
//                       splashColor: Colors.greenAccent),
//                   IconButton(
//                       icon: Icon(Icons.stop),
//                       onPressed: isStopped ? null : () => _stop(),
//                       color: Colors.red,
//                       splashColor: Colors.redAccent),
//                   DropdownButton(
//                     value: language,
//                     items: getDropDownMenuItems(),
//                     onChanged: changedDropDownItem,
//                   )
//                 ]))
//       ]);

//   void onMicPressed() {
//     if(_isAvailable && !_isListening) {
//       _speechRecognition.listen(locale: "en_IN").then((result) => print('$result'));
//     }
//   }

//   void onCancelPressed() {
//     if(_isListening) {
//       _speechRecognition.cancel().then((result) => setState(() {
//         _isListening = result;
//         resultText = "";
//       }));
//     }
//   }

//   void onStopPressed() {
//     if(_isListening) {
//       _speechRecognition.stop().then((result) => setState(() {
//         _isListening = result;
//       }));
//     }
//   }

// }