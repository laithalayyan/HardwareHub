import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../curved_edges/curved_edges_widget.dart';
import 'rounded_container.dart';


class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({
    super.key, required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurveEdgeWidget(
      child: Container(
        color: TColors.primary,
        //padding: const EdgeInsets.all(0),
        //child: SizedBox(
          //height: 370,
          child: Stack(
            children: [
              Positioned(top: -150, right: -250, child: TRoundedContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),radius: 1000,width: 400,height: 400,)),
              Positioned(top: 100, right: -300, child: TRoundedContainer(backgroundColor: TColors.textWhite.withOpacity(0.1),radius: 800,width: 400,height: 400)),
              child,
            ],
          ),
        //),
      ),
    );
  }
}
