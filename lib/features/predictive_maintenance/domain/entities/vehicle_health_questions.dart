class VehicleHealthQuestions {
  static const Map<String, List<Map<String, dynamic>>> questionsByComponent = {
    'Engine': [
      {
        'question': 'Does your engine start smoothly?',
        'type': 'yesno',
        'weight': 10,
      },
      {
        'question': 'Is the check engine light on?',
        'type': 'yesno',
        'weight': -15,
      },
      {
        'question': 'How is the engine performance?',
        'type': 'rating',
        'weight': 12,
      },
      {
        'question': 'Any unusual engine noises?',
        'type': 'yesno',
        'weight': -10,
      },
      {
        'question': 'When was your last oil change?',
        'type': 'duration',
        'options': ['< 3 months', '3-6 months', '6-12 months', '> 12 months'],
        'weights': [10, 5, -5, -15],
      },
      {
        'question': 'Any oil leaks noticed?',
        'type': 'yesno',
        'weight': -12,
      },
    ],
    'Brakes': [
      {
        'question': 'Do brakes respond smoothly?',
        'type': 'yesno',
        'weight': 12,
      },
      {
        'question': 'Any squealing or grinding noise when braking?',
        'type': 'yesno',
        'weight': -15,
      },
      {
        'question': 'How effective are your brakes?',
        'type': 'rating',
        'weight': 15,
      },
      {
        'question': 'When were brake pads last replaced?',
        'type': 'duration',
        'options': ['< 6 months', '6-12 months', '1-2 years', '> 2 years'],
        'weights': [12, 8, 0, -10],
      },
      {
        'question': 'Does the car pull to one side when braking?',
        'type': 'yesno',
        'weight': -10,
      },
    ],
    'Transmission': [
      {
        'question': 'Do gears shift smoothly?',
        'type': 'yesno',
        'weight': 12,
      },
      {
        'question': 'Any slipping or delayed engagement?',
        'type': 'yesno',
        'weight': -15,
      },
      {
        'question': 'When was transmission fluid last changed?',
        'type': 'duration',
        'options': ['< 1 year', '1-2 years', '2-3 years', '> 3 years'],
        'weights': [10, 5, -5, -12],
      },
      {
        'question': 'Any grinding or shaking during gear changes?',
        'type': 'yesno',
        'weight': -12,
      },
    ],
    'Battery': [
      {
        'question': 'Does the car start without hesitation?',
        'type': 'yesno',
        'weight': 10,
      },
      {
        'question': 'Age of your battery?',
        'type': 'duration',
        'options': ['< 1 year', '1-2 years', '2-3 years', '> 3 years'],
        'weights': [15, 10, 5, -10],
      },
      {
        'question': 'Any electrical issues (dim lights, etc.)?',
        'type': 'yesno',
        'weight': -12,
      },
      {
        'question': 'Battery terminals clean and tight?',
        'type': 'yesno',
        'weight': 8,
      },
    ],
    'Tires': [
      {
        'question': 'Tire tread depth adequate?',
        'type': 'yesno',
        'weight': 12,
      },
      {
        'question': 'Tire pressure checked regularly?',
        'type': 'yesno',
        'weight': 8,
      },
      {
        'question': 'Any uneven tire wear?',
        'type': 'yesno',
        'weight': -10,
      },
      {
        'question': 'When were tires last rotated?',
        'type': 'duration',
        'options': ['< 6 months', '6-12 months', '> 12 months', 'Never'],
        'weights': [10, 5, -5, -12],
      },
      {
        'question': 'Any vibration at high speeds?',
        'type': 'yesno',
        'weight': -8,
      },
    ],
    'Fluids': [
      {
        'question': 'Coolant level adequate?',
        'type': 'yesno',
        'weight': 10,
      },
      {
        'question': 'Brake fluid level good?',
        'type': 'yesno',
        'weight': 10,
      },
      {
        'question': 'Power steering fluid level adequate?',
        'type': 'yesno',
        'weight': 8,
      },
      {
        'question': 'Any fluid leaks noticed?',
        'type': 'yesno',
        'weight': -15,
      },
      {
        'question': 'When was coolant last flushed?',
        'type': 'duration',
        'options': ['< 1 year', '1-2 years', '2-3 years', '> 3 years'],
        'weights': [8, 5, 0, -8],
      },
    ],
    'Suspension': [
      {
        'question': 'Is the ride smooth and comfortable?',
        'type': 'rating',
        'weight': 10,
      },
      {
        'question': 'Any clunking noises over bumps?',
        'type': 'yesno',
        'weight': -12,
      },
      {
        'question': 'Does the car bounce excessively?',
        'type': 'yesno',
        'weight': -10,
      },
      {
        'question': 'Wheel alignment recently checked?',
        'type': 'yesno',
        'weight': 8,
      },
    ],
  };

  static int getTotalQuestions() {
    int total = 0;
    questionsByComponent.forEach((_, questions) {
      total += questions.length;
    });
    return total;
  }

  static List<String> getComponents() {
    return questionsByComponent.keys.toList();
  }
}
