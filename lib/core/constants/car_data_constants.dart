/// Common car data constants for autocomplete suggestions
class CarDataConstants {
  // Popular car brands in India
  static const List<String> brands = [
    'Maruti Suzuki',
    'Hyundai',
    'Tata',
    'Mahindra',
    'Kia',
    'Honda',
    'Toyota',
    'Renault',
    'Nissan',
    'Volkswagen',
    'Skoda',
    'MG',
    'Jeep',
    'Ford',
    'Chevrolet',
    'Fiat',
    'Datsun',
  ];

  // Popular models by brand
  static const Map<String, List<String>> modelsByBrand = {
    'Maruti Suzuki': ['Swift', 'Baleno', 'Dzire', 'Alto', 'WagonR', 'Ertiga', 'Vitara Brezza', 'S-Cross', 'Ciaz', 'XL6'],
    'Hyundai': ['i20', 'Creta', 'Venue', 'Verna', 'Grand i10 Nios', 'Aura', 'Alcazar', 'Tucson', 'Elantra'],
    'Tata': ['Nexon', 'Harrier', 'Safari', 'Punch', 'Altroz', 'Tiago', 'Tigor', 'Hexa'],
    'Mahindra': ['Scorpio', 'XUV700', 'XUV300', 'Thar', 'Bolero', 'Marazzo', 'Alturas G4'],
    'Kia': ['Seltos', 'Sonet', 'Carens', 'Carnival', 'EV6'],
    'Honda': ['City', 'Amaze', 'Jazz', 'WR-V', 'Civic', 'CR-V'],
    'Toyota': ['Fortuner', 'Innova Crysta', 'Glanza', 'Urban Cruiser', 'Camry', 'Vellfire'],
    'Renault': ['Kwid', 'Triber', 'Kiger', 'Duster'],
    'Nissan': ['Magnite', 'Kicks', 'GT-R'],
    'Volkswagen': ['Polo', 'Vento', 'Taigun', 'Tiguan'],
    'Skoda': ['Rapid', 'Kushaq', 'Octavia', 'Superb', 'Kodiaq'],
    'MG': ['Hector', 'Astor', 'ZS EV', 'Gloster'],
  };

  // Fuel types
  static const List<String> fuelTypes = [
    'Petrol',
    'Diesel',
    'CNG',
    'Electric',
    'Hybrid',
    'LPG',
  ];

  // Transmission types
  static const List<String> transmissions = [
    'Manual',
    'Automatic',
    'CVT',
    'AMT',
    'DCT',
  ];

  // Indian states
  static const List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Trivandrum',
    'Kollam',
    
  ];

  // Major cities
  static const List<String> cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Surat',
    'Jaipur',
    'Lucknow',
    'Kanpur',
    'Nagpur',
    'Indore',
    'Thane',
    'Bhopal',
    'Visakhapatnam',
    'Pimpri-Chinchwad',
    'Patna',
    'Vadodara',
    'Ghaziabad',
    'Ludhiana',
    'Agra',
    'Nashik',
    'Faridabad',
    'Meerut',
    'Rajkot',
    'Kalyan-Dombivali',
    'Vasai-Virar',
    'Varanasi',
  ];

  // Ownership types
  static const List<String> ownershipTypes = [
    'First Owner',
    'Second Owner',
    'Third Owner',
    'Fourth+ Owner',
  ];

  // Usage types
  static const List<String> usageTypes = [
    'Personal',
    'Commercial',
    'Taxi',
  ];

  // Insurance policy types
  static const List<String> policyTypes = [
    'Comprehensive',
    'Third Party',
    'Zero Depreciation',
  ];

  // Popular insurance providers
  static const List<String> insuranceProviders = [
    'HDFC ERGO',
    'ICICI Lombard',
    'Bajaj Allianz',
    'Reliance General',
    'Tata AIG',
    'New India Assurance',
    'National Insurance',
    'Oriental Insurance',
    'United India Insurance',
    'SBI General',
  ];

  /// Get models for a specific brand
  static List<String> getModelsForBrand(String brand) {
    return modelsByBrand[brand] ?? [];
  }

  /// Get all models (flattened)
  static List<String> getAllModels() {
    return modelsByBrand.values.expand((models) => models).toList();
  }
}
