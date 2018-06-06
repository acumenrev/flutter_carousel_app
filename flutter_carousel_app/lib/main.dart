import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'card_data.dart';

void main() {
  // Set status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _scrollPercent = 0.0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      backgroundColor: Colors.black,
      body: new Column(
        children: <Widget>[
          // status bar
          createStatusBar(),
          // cards
          createCards(),
          // bottom bar
          createBottomBar()
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget createStatusBar() {
    return new Container(
      width: double.infinity,
      height: 20.0,
    );
  }

  Widget createCards() {
    return new Expanded(
        child: new CardClipper(
      cards: listSampleCards,
      onScrolling: (double scrollPercent) {
        setState(() {
          this._scrollPercent = scrollPercent;
        });
      },
    ));
  }

  Widget createBottomBar() {
    return new BottomBar(
        cardsLength: listSampleCards.length, scrollPercent: _scrollPercent);
  }
}

class BottomBar extends StatelessWidget {
  final int cardsLength;
  final double scrollPercent;

  BottomBar({this.cardsLength = 0, this.scrollPercent = 0.0});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
              child: new Center(
            child: new Icon(Icons.settings, color: Colors.white),
          )),
          new Expanded(
              child: new Container(
            width: double.infinity,
            height: 5.0,
            child: new ScrollIndicator(
                itemsCount: cardsLength, scrollPercent: scrollPercent),
          )),
          new Expanded(
              child: new Center(
            child: new Icon(Icons.add, color: Colors.white),
          ))
        ],
      ),
    );
  }
}

class ScrollIndicator extends StatelessWidget {
  final int itemsCount;
  final double scrollPercent;

  ScrollIndicator({this.itemsCount = 0, this.scrollPercent = 0.0});

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new ScrollIndicatorPainter(
          itemsCount: itemsCount, scrollPercent: scrollPercent),
      child: new Container(),
    );
  }
}

class ScrollIndicatorPainter extends CustomPainter {
  final int itemsCount;
  final double scrollPercent;
  final Paint trackPaint;
  final Paint thumbPaint;

  ScrollIndicatorPainter({this.itemsCount = 0, this.scrollPercent = 0.0})
      : trackPaint = new Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.fill,
        thumbPaint = new Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw track
    canvas.drawRRect(
        new RRect.fromRectAndCorners(
            new Rect.fromLTWH(0.0, 0.0, size.width, size.height),
            topLeft: new Radius.circular(3.0),
            topRight: new Radius.circular(3.0),
            bottomLeft: new Radius.circular(3.0),
            bottomRight: new Radius.circular(3.0)),
        trackPaint);

    // Draw thumb
    final thumbWidth = size.width / itemsCount;
    final thumbLeft = size.width * scrollPercent;

    canvas.drawRRect(
        new RRect.fromRectAndCorners(
            new Rect.fromLTWH(thumbLeft, 0.0, thumbWidth, size.height),
            topLeft: new Radius.circular(3.0),
            topRight: new Radius.circular(3.0),
            bottomLeft: new Radius.circular(3.0),
            bottomRight: new Radius.circular(3.0)),
        thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CardClipper extends StatefulWidget {
  final List<CardViewModel> cards;
  final Function(double scrollPercent) onScrolling;

  CardClipper({Key key, this.cards, this.onScrolling}) : super(key: key);

  @override
  _CardClipperState createState() => _CardClipperState();
}

class _CardClipperState extends State<CardClipper>
    with TickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishScrollController;

  List<Widget> _buildCards() {
    final cardCounts = widget.cards.length;

    int index = -1;
    return widget.cards.map((CardViewModel viewModel) {
      ++index;
      return _buildCard(viewModel, index, cardCounts, scrollPercent);
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    finishScrollController = new AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    finishScrollController.addListener(() {
      setState(() {
        scrollPercent = lerpDouble(
            finishScrollStart, finishScrollEnd, finishScrollController.value);
        if (widget.onScrolling != null) {
          widget.onScrolling(scrollPercent);
        }
      });
    });
  }

  @override
  void dispose() {
    finishScrollController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;

    setState(() {
      scrollPercent = (startDragPercentScroll +
              (-singleCardDragPercent / widget.cards.length))
          .clamp(0.0, 1.0 - (1 / widget.cards.length));
      if (widget.onScrolling != null) {
        widget.onScrolling(scrollPercent);
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    finishScrollStart = scrollPercent;
    finishScrollEnd =
        (scrollPercent * widget.cards.length).round() / widget.cards.length;
    finishScrollController.forward(from: 0.0);

    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: new Stack(
        children: _buildCards(),
      ),
    );
  }

  Widget _buildCard(CardViewModel viewModel, int cardIndex, int cardCount,
      double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    final parallax = scrollPercent - (cardIndex / cardCount);

    return new FractionalTranslation(
      translation: new Offset(cardIndex - cardScrollPercent, 0.0),
      child: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Card(viewModel: viewModel, parallaxPercent: parallax),
      ),
    );
  }
}

class Card extends StatelessWidget {
  final CardViewModel viewModel;
  final double parallaxPercent;
  Card({this.viewModel, this.parallaxPercent = 0.0});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // background
        new ClipRRect(
            borderRadius: new BorderRadius.circular(10.0),
            child: new FractionalTranslation(
                translation: new Offset(parallaxPercent * 2.0, 0.0),
                child: new OverflowBox(
                    maxWidth: double.infinity,
                    child: new Image.asset(this.viewModel.backgroundAssetPath,
                        fit: BoxFit.cover)))),

        // content
        new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding:
                  const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
              child: new Text(
                this.viewModel.address.toUpperCase(),
                style: new TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
              ),
            ),
            new Expanded(child: new Container()),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  '${this.viewModel.minHeightInFeet} - ${this.viewModel.maxHeightInFeet}',
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 140.0,
                      letterSpacing: -5.0),
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 30.0),
                  child: new Text(
                    'FT',
                    style: new TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: new Text(
                    '${this.viewModel.tempInDegrees}',
                    style: new TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ],
            ),
            new Expanded(child: new Container()),
            new Padding(
              padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
              child: new Container(
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(30.0),
                    border: new Border.all(color: Colors.white, width: 1.5),
                    color: Colors.black.withOpacity(0.3)),
                child: new Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Text(
                        this.viewModel.weatherType,
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: new Icon(
                          Icons.wb_cloudy,
                          color: Colors.white,
                        ),
                      ),
                      new Text(
                        '${this.viewModel.windSpeedMph}mph',
                        style: new TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
