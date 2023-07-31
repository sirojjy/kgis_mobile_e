import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import './scalebar_utils.dart' as util;

///LayerOptions -> MapOption
class ScaleLayerPluginOption extends MapOptions {
  final TextStyle textStyle;
  final Color lineColor;
  final double lineWidth;
  final EdgeInsets padding;

  ScaleLayerPluginOption({
    required Key key,
    required this.textStyle,
    this.lineColor = Colors.white,
    this.lineWidth = 2,
    required this.padding,
    rebuild,
  });
}
///MapPluginLayer -> MapOptions
class ScaleLayerPlugin extends MapOptions  {
  Widget createLayer(
      ///MapState mapState ->  mapState
      MapOptions options, mapState, Stream<Null> stream) {
    if (options is ScaleLayerPluginOption) {
      return ScaleLayer(options, mapState, stream);
    }
    throw Exception('Unknown options type for ScaleLayerPlugin: $options');
  }

  bool supportsLayer(MapOptions options) {
    return options is ScaleLayerPluginOption;
  }
}

class ScaleLayer extends StatelessWidget {
  final ScaleLayerPluginOption scaleLayerOpts;
  final FlutterMapState map;
  final Stream<Null> stream;
  final scale = [
    25000000,
    15000000,
    8000000,
    4000000,
    2000000,
    1000000,
    500000,
    250000,
    100000,
    50000,
    25000,
    15000,
    8000,
    4000,
    2000,
    1000,
    500,
    250,
    100,
    50,
    25,
    10,
    5
  ];

  ScaleLayer(this.scaleLayerOpts, this.map, this.stream);
      // : super(key: scaleLayerOpts.key);

  @override
  Widget build(BuildContext context) {
    var zoom = map.zoom;
    var distance = scale[max(0, min(20, zoom.round() + 2))].toDouble();
    var center = map.center;
    var start = map.project(center);
    var targetPoint =
        util.calculateEndingGlobalCoordinates(center, 90, distance);
    var end = map.project(targetPoint);
    var displayDistance = distance > 999
        ? '${(distance / 1000).toStringAsFixed(0)} km'
        : '${distance.toStringAsFixed(0)} m';
    double width = (end.x - start.x).toDouble();

    return CustomPaint(
      painter: ScalePainter(
        width,
        displayDistance,
        lineColor: scaleLayerOpts.lineColor,
        lineWidth: scaleLayerOpts.lineWidth,
        padding: scaleLayerOpts.padding,
        textStyle: scaleLayerOpts.textStyle,
      ),
    );
  }
}

class ScalePainter extends CustomPainter {
  ScalePainter(this.width, this.text,
      {required this.padding, required this.textStyle, required this.lineWidth, required this.lineColor});
  final double width;
  final EdgeInsets padding;
  final String text;
  TextStyle textStyle;
  double lineWidth;
  Color lineColor;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.square
      ..strokeWidth = lineWidth;

    double sizeForStartEnd = 4;
    double paddingLeft = padding == null ? 0 : padding.left + sizeForStartEnd / 2;
    double paddingTop = padding == null ? 0 : padding.top;

    var textSpan = TextSpan(style: textStyle, text: text);
    var textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas,
        Offset(width / 2 - textPainter.width / 2 + paddingLeft, paddingTop.toDouble()));
    paddingTop += textPainter.height;
    var p1 = Offset(paddingLeft, sizeForStartEnd + paddingTop);
    var p2 = Offset(paddingLeft + width, sizeForStartEnd + paddingTop);
    // draw start line
    canvas.drawLine(Offset(paddingLeft, paddingTop),
        Offset(paddingLeft, sizeForStartEnd + paddingTop), paint);
    // draw middle line
    var middleX = width / 2 + paddingLeft - lineWidth / 2;
    canvas.drawLine(Offset(middleX, paddingTop + sizeForStartEnd / 2),
        Offset(middleX, sizeForStartEnd + paddingTop), paint);
    // draw end line
    canvas.drawLine(Offset(width + paddingLeft, paddingTop),
        Offset(width + paddingLeft, sizeForStartEnd + paddingTop), paint);
    // draw bottom line
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}