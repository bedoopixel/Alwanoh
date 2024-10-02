import 'package:flutter/material.dart';
import '../ChatPage.dart';
import '../Thems/styles.dart';


class OrderStatePage extends StatefulWidget {
  @override
  _OrderStatePageState createState() => _OrderStatePageState();
}

class _OrderStatePageState extends State<OrderStatePage> {
  int _currentStep = 0; // Tracks the current order state step

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status'),
        backgroundColor: Styles.customColor, // Using customColor from Styles
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: Colors.black, // Change the primary color for Stepper
          colorScheme: ColorScheme.light(primary: Colors.black), // Update the color scheme
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9), // Set color with 90% opacity
            image: DecorationImage(
              image: AssetImage('assets/back.png'), // Background image
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track your order:',
                style: TextStyle(
                  color: Styles.customColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Stepper(
                currentStep: _currentStep,
                onStepContinue: _currentStep < 2
                    ? () {
                  setState(() {
                    _currentStep++;
                  });
                }
                    : null, // Stops at Delivered state
                onStepCancel: _currentStep > 0
                    ? () {
                  setState(() {
                    _currentStep--;
                  });
                }
                    : null,
                steps: _buildOrderSteps(),
                controlsBuilder: (BuildContext context, ControlsDetails details) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentStep < 2)
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.customColor, // Using primaryColor
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(color: Colors.white), // Ensuring text is white
                          ),
                        ),
                      SizedBox(width: 8),
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Styles.customColor), // Border color
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(color: Styles.customColor), // Custom text color
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage()), // Navigate to ChatPage
          );
        },
        backgroundColor: Styles.customColor,
        child: Icon(Icons.chat, color: Colors.white), // Chat icon
      ),
    );
  }

  // Method to create the steps of the order process
  List<Step> _buildOrderSteps() {
    return [
      _createStep('Being Prepped', 'Your order is currently being prepared.'),
      _createStep('On Way', 'Your order is on the way to the delivery address.'),
      _createStep('Delivered', 'Your order has been delivered.'),
    ];
  }

  Step _createStep(String title, String content) {
    return Step(
      title: Text(
        title,
        style: TextStyle(color: Styles.customColor), // Custom title color
      ),
      content: Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              content,
              style: TextStyle(color: Colors.white), // Custom content color
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep == _getStepIndex(title)
          ? StepState.editing
          : _currentStep > _getStepIndex(title)
          ? StepState.complete
          : StepState.indexed,
    );
  }

  int _getStepIndex(String title) {
    switch (title) {
      case 'Being Prepped':
        return 0;
      case 'On Way':
        return 1;
      case 'Delivered':
        return 2;
      default:
        return -1;
    }
  }
}
