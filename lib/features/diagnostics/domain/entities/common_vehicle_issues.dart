class CommonVehicleIssues {
  static const Map<String, List<Map<String, String>>> issuesByCategory = {
    'Engine': [
      {
        'symptom': 'Engine won\'t start',
        'causes': 'Dead battery, faulty starter, fuel pump failure, ignition issues',
        'severity': 'high',
      },
      {
        'symptom': 'Check engine light on',
        'causes': 'Oxygen sensor, catalytic converter, mass airflow sensor, spark plugs',
        'severity': 'medium',
      },
      {
        'symptom': 'Engine overheating',
        'causes': 'Low coolant, radiator issues, thermostat failure, water pump failure',
        'severity': 'critical',
      },
      {
        'symptom': 'Poor acceleration',
        'causes': 'Clogged fuel filter, faulty fuel pump, dirty air filter, spark plug issues',
        'severity': 'medium',
      },
      {
        'symptom': 'Engine misfiring',
        'causes': 'Bad spark plugs, ignition coil failure, fuel injector problems',
        'severity': 'high',
      },
      {
        'symptom': 'Excessive smoke from exhaust',
        'causes': 'Oil burning (blue), coolant leak (white), rich fuel mixture (black)',
        'severity': 'high',
      },
    ],
    'Brakes': [
      {
        'symptom': 'Squealing or grinding noise',
        'causes': 'Worn brake pads, damaged rotors, lack of lubrication',
        'severity': 'high',
      },
      {
        'symptom': 'Soft or spongy brake pedal',
        'causes': 'Air in brake lines, brake fluid leak, worn master cylinder',
        'severity': 'critical',
      },
      {
        'symptom': 'Vibration when braking',
        'causes': 'Warped rotors, uneven brake pad wear, suspension issues',
        'severity': 'medium',
      },
      {
        'symptom': 'Brake warning light on',
        'causes': 'Low brake fluid, worn brake pads, ABS system fault',
        'severity': 'high',
      },
      {
        'symptom': 'Car pulls to one side when braking',
        'causes': 'Uneven brake pad wear, stuck caliper, contaminated brake fluid',
        'severity': 'high',
      },
    ],
    'Transmission': [
      {
        'symptom': 'Slipping gears',
        'causes': 'Low transmission fluid, worn clutch, faulty solenoid',
        'severity': 'high',
      },
      {
        'symptom': 'Delayed engagement',
        'causes': 'Low fluid level, worn transmission bands, valve body issues',
        'severity': 'medium',
      },
      {
        'symptom': 'Grinding or shaking',
        'causes': 'Worn gears, clutch problems, transmission mount failure',
        'severity': 'high',
      },
      {
        'symptom': 'Transmission fluid leak',
        'causes': 'Damaged seals, loose pan bolts, cracked transmission case',
        'severity': 'high',
      },
    ],
    'Electrical': [
      {
        'symptom': 'Battery keeps dying',
        'causes': 'Faulty alternator, parasitic drain, old battery, corroded terminals',
        'severity': 'medium',
      },
      {
        'symptom': 'Headlights dim or flickering',
        'causes': 'Weak battery, failing alternator, loose connections',
        'severity': 'medium',
      },
      {
        'symptom': 'Power windows not working',
        'causes': 'Blown fuse, faulty switch, window motor failure',
        'severity': 'low',
      },
      {
        'symptom': 'Dashboard warning lights',
        'causes': 'Sensor failures, electrical faults, system malfunctions',
        'severity': 'medium',
      },
    ],
    'Suspension': [
      {
        'symptom': 'Bumpy or rough ride',
        'causes': 'Worn shock absorbers, damaged struts, broken springs',
        'severity': 'medium',
      },
      {
        'symptom': 'Car pulls to one side',
        'causes': 'Wheel alignment issues, uneven tire wear, suspension damage',
        'severity': 'medium',
      },
      {
        'symptom': 'Excessive bouncing',
        'causes': 'Worn shocks, damaged struts, weak springs',
        'severity': 'medium',
      },
      {
        'symptom': 'Clunking noise over bumps',
        'causes': 'Worn ball joints, damaged control arms, loose sway bar links',
        'severity': 'medium',
      },
    ],
    'Tires': [
      {
        'symptom': 'Uneven tire wear',
        'causes': 'Poor alignment, improper inflation, suspension issues',
        'severity': 'medium',
      },
      {
        'symptom': 'Vibration at high speed',
        'causes': 'Unbalanced tires, bent rim, worn suspension components',
        'severity': 'medium',
      },
      {
        'symptom': 'Tire pressure warning light',
        'causes': 'Low tire pressure, faulty TPMS sensor, temperature changes',
        'severity': 'low',
      },
    ],
    'AC/Heating': [
      {
        'symptom': 'AC not cooling',
        'causes': 'Low refrigerant, compressor failure, clogged condenser',
        'severity': 'low',
      },
      {
        'symptom': 'Heater not working',
        'causes': 'Low coolant, faulty thermostat, heater core blockage',
        'severity': 'low',
      },
      {
        'symptom': 'Strange smell from vents',
        'causes': 'Mold in AC system, clogged cabin filter, coolant leak',
        'severity': 'medium',
      },
    ],
    'Fuel System': [
      {
        'symptom': 'Poor fuel economy',
        'causes': 'Dirty air filter, faulty oxygen sensor, fuel injector issues',
        'severity': 'low',
      },
      {
        'symptom': 'Fuel smell',
        'causes': 'Fuel leak, loose gas cap, damaged fuel lines',
        'severity': 'high',
      },
      {
        'symptom': 'Engine stalling',
        'causes': 'Fuel pump failure, clogged fuel filter, bad fuel injectors',
        'severity': 'high',
      },
    ],
  };

  static List<String> getAllSymptoms() {
    List<String> symptoms = [];
    issuesByCategory.forEach((category, issues) {
      for (var issue in issues) {
        symptoms.add('${issue['symptom']} ($category)');
      }
    });
    return symptoms;
  }

  static Map<String, String>? getIssueDetails(String symptom) {
    for (var issues in issuesByCategory.values) {
      for (var issue in issues) {
        if (issue['symptom'] == symptom) {
          return issue;
        }
      }
    }
    return null;
  }
}
