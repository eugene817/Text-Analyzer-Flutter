import 'package:drzewo_ginealogiczne/logic.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MainApp());
}


class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {


  //class variables
  final TextEditingController searchText = TextEditingController();
  List<SearchResult> _searchResults = [];
  String mostFrequentWord = '';
  String leastFrequentWord = '';
  List<String> suggestions = [];

  
  String _selectedAlgorithm = 'KMP';
  final List<String> _algorithms = ['KMP', 'Rabin-Karp'];

  String fileText = '';


  @override
  void initState() {
    super.initState();
    searchText.addListener(_onSearchChanged);
  }


  void _onSearchChanged() {
    String lastWord = searchText.text.split(' ').last;
    setState(() {
      suggestions = lastWord.isNotEmpty ? suggestCorrections(lastWord, fileText, 2) : [];
    });
  }

  @override
  void dispose() {
    searchText.removeListener(_onSearchChanged);
    searchText.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    //variables
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: const Center(child: Text("File Analyzer")),
        ),




        //File input
        body: Builder( 
          builder: (BuildContext context) {
            return 
            
            //file picking + choosing algorithm
            Column(
              children: [
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    //file picking
                    Center(
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: width * 0.2,
                          minHeight: height * 0.06,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade100,
                          border: Border.all(
                            color: Colors.black12,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () => _pickFile(context),
                          child: const Text(
                            "Pick a File",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width*0.01,),
                    

                    //button to choose algorithm
                    Container(
                      constraints: BoxConstraints(
                        minWidth: width * 0.12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        border: Border.all(
                          color: Colors.black12,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: DropdownButton<String>(
                        value: _selectedAlgorithm,
                        onChanged: (value) {
                          _onSearchChanged();
                        },
                        items: _algorithms.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 20,
                        elevation: 16,
                        style: TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 0,
                        ),
                        dropdownColor: Colors.deepOrange.shade300, 
                        borderRadius: BorderRadius.circular(20),
                      ),
                    )
                  ],
                ),


                // Text input + button
                SizedBox(height: height*0.05,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    //Text input
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: width * 0.56,
                      ),
                      child: TextField(
                        controller: searchText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          hintText: "Enter a searched item",
                          filled: true,
                          hoverColor: Colors.deepOrange.shade200,
                          fillColor: Colors.deepOrange.shade200,
                          focusColor: Colors.deepOrange.shade200,
                        ),
                          onChanged: (context) {
                            setState(() {
                              suggestions = suggestCorrections(context, fileText, 2);
                              _onSearchChanged();
                            });
                          },
                      ),
                    ),


                    SizedBox(width: width * 0.01,),


                //buton
                FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.deepOrange.shade300,
                  onPressed: () => _searchText(context),
                  child: const Icon(Icons.text_fields),
                ),
                  ],
                ),
                  if (suggestions.isNotEmpty)
                    Container(
                      height: 100,
                      width: width*0.2,
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(suggestions[index]),
                            onTap: () {
                              String currentText = searchText.text;
                              List<String> words = currentText.split(' ');
                              words.removeLast();
                              words.add(suggestions[index]); 
                              String newText = words.join(' ') + ' '; 

                              searchText.value = TextEditingValue(
                                text: newText,
                                selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
                              );

                              setState(() {
                                _onSearchChanged();
                              });
                            },
                          );
                        },
                      ),
                    ),
                SizedBox(height: height*0.05,),


                //file text
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                        constraints: BoxConstraints(
                          maxWidth: width * 0.9,
                        ),
                        child: _searchResults.isEmpty
                        ? Text(
                          fileText,
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        )
                        : _highlightSearchResults(fileText, _searchResults),
                      ),
                  )
                )
              ],
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
        elevation: 10,
        color: Colors.deepOrangeAccent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Chip(
                label: Text('$mostFrequentWord', style: TextStyle(fontSize: 20),),
                avatar: Icon(Icons.trending_up),
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
              ),
              Chip(
                label: Text('$leastFrequentWord', style: TextStyle(fontSize: 20),),
                avatar: Icon(Icons.trending_down),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
            ],
          ),
        ),
    ),
      ),
    );
  }

 
 //file picking
 void _pickFile(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    String? fileContent = await readFile(result);
    Map<String, int> wordFreq = countWordFrequency(fileContent);

    String mfw = getMostFrequentWord(wordFreq);
    String lfw = getLeastFrequentWord(wordFreq);  
    setState(() {
      fileText = fileContent;
      mostFrequentWord = mfw;
      leastFrequentWord = lfw;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Selected file: ${result.names} "),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("File picking canceled"),
      ),
    );
  }
}


//file searching
void _searchText(BuildContext context) async {
  if (searchText.text.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(content: Text("Enter a search term")),
    );
    return;
  }

  List<int> positions = [];
  if (_selectedAlgorithm == 'KMP') {
    positions = kmpSearch(fileText, searchText.text);
  } else if (_selectedAlgorithm == 'Rabin-Karp') {
    positions = rabinKarpSearch(fileText, searchText.text);
  }

  _searchResults = [];
  for (var pos in positions) {
    int lineNumber = _getLineNumberForPosition(fileText, pos);
    _searchResults.add(SearchResult(pos, pos + searchText.text.length, lineNumber));
  }

  int totalMatches = _searchResults.length;
  List<int> linesWithMatches = _searchResults.map((r) => r.lineNumber).toSet().toList();


  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Results of searching"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("Total Matches: $totalMatches"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Nice'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  setState(() {});
}


//for search
int _getLineNumberForPosition(String text, int pos) {
  return '\n'.allMatches(text.substring(0, pos)).length + 1;
}


//searched text
RichText _highlightSearchResults(String text, List<SearchResult> results) {
  List<TextSpan> spans = [];
  int start = 0;

  for (var result in results) {
    if (result.start > start) {
      spans.add(TextSpan(text: text.substring(start, result.start),
      style: TextStyle(fontSize: 30)
      ));
    }
    spans.add(TextSpan(
      text: text.substring(result.start, result.end),
      style: TextStyle(
        backgroundColor: Colors.yellow,
        fontSize: 30,
        ),
    ));
    start = result.end;
  }
   if (start < text.length) {
    spans.add(TextSpan(
      text: text.substring(start),
      style: TextStyle(fontSize: 30), 
    ));
  }

  return RichText(
    text: TextSpan(
      children: spans,
      style: TextStyle(fontSize: 30, color: Colors.black),
    ),
  );
  }


  //char freq
  String getCharacterFrequencyString(Map<String, int> charFreq) {
  return charFreq.entries.map((e) => '${e.key}: ${e.value}').join(', ');
}


//levenstein integration
List<String> suggestCorrections(String input, String text, int maxDistance) {
  Set<String> uniqueWords = Set.from(text.split(RegExp(r'\W+')));
  return uniqueWords.where((word) => levenshteinDistance(input, word) <= maxDistance).toList();
}

}