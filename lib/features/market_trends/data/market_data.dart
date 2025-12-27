class MarketData {
  // Top selling new cars in India (2024 data)
  static const List<Map<String, dynamic>> topSellingNewCars = [
    {
      'name': 'Maruti Suzuki Alto',
      'sales': 25000,
      'avgPrice': 550000,
      'priceChange': 2.5, // percentage
      'segment': 'Hatchback',
    },
    {
      'name': 'Maruti Suzuki Swift',
      'sales': 22000,
      'avgPrice': 750000,
      'priceChange': 3.2,
      'segment': 'Hatchback',
    },
    {
      'name': 'Maruti Suzuki Wagon R',
      'sales': 20000,
      'avgPrice': 600000,
      'priceChange': 1.8,
      'segment': 'Hatchback',
    },
    {
      'name': 'Hyundai Creta',
      'sales': 18000,
      'avgPrice': 1500000,
      'priceChange': 4.5,
      'segment': 'SUV',
    },
    {
      'name': 'Tata Nexon',
      'sales': 16000,
      'avgPrice': 1200000,
      'priceChange': 5.2,
      'segment': 'SUV',
    },
    {
      'name': 'Maruti Suzuki Baleno',
      'sales': 15000,
      'avgPrice': 850000,
      'priceChange': 2.1,
      'segment': 'Hatchback',
    },
    {
      'name': 'Hyundai Venue',
      'sales': 14000,
      'avgPrice': 1100000,
      'priceChange': 3.8,
      'segment': 'SUV',
    },
    {
      'name': 'Tata Punch',
      'sales': 13000,
      'avgPrice': 700000,
      'priceChange': 6.5,
      'segment': 'SUV',
    },
  ];

  // Top selling second-hand cars
  static const List<Map<String, dynamic>> topSellingUsedCars = [
    {
      'name': 'Maruti Suzuki Swift (2018-2020)',
      'sales': 8000,
      'avgPrice': 450000,
      'priceChange': -5.2, // depreciation
      'segment': 'Hatchback',
    },
    {
      'name': 'Hyundai i20 (2017-2019)',
      'sales': 7500,
      'avgPrice': 500000,
      'priceChange': -6.1,
      'segment': 'Hatchback',
    },
    {
      'name': 'Honda City (2016-2018)',
      'sales': 7000,
      'avgPrice': 650000,
      'priceChange': -7.5,
      'segment': 'Sedan',
    },
    {
      'name': 'Maruti Suzuki Alto (2018-2020)',
      'sales': 6500,
      'avgPrice': 250000,
      'priceChange': -8.2,
      'segment': 'Hatchback',
    },
    {
      'name': 'Hyundai Creta (2018-2020)',
      'sales': 6000,
      'avgPrice': 950000,
      'priceChange': -6.8,
      'segment': 'SUV',
    },
    {
      'name': 'Tata Nexon (2019-2021)',
      'sales': 5500,
      'avgPrice': 750000,
      'priceChange': -5.5,
      'segment': 'SUV',
    },
    {
      'name': 'Maruti Suzuki Wagon R (2017-2019)',
      'sales': 5000,
      'avgPrice': 300000,
      'priceChange': -7.8,
      'segment': 'Hatchback',
    },
    {
      'name': 'Ford EcoSport (2016-2018)',
      'sales': 4500,
      'avgPrice': 550000,
      'priceChange': -9.2,
      'segment': 'SUV',
    },
  ];

  // Price trends over months (last 6 months)
  static const List<Map<String, dynamic>> priceTrends = [
    {'month': 'Jul', 'new': 100, 'used': 100},
    {'month': 'Aug', 'new': 101, 'used': 98},
    {'month': 'Sep', 'new': 103, 'used': 96},
    {'month': 'Oct', 'new': 105, 'used': 94},
    {'month': 'Nov', 'new': 107, 'used': 92},
    {'month': 'Dec', 'new': 110, 'used': 90},
  ];

  static String formatPrice(double price) {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }

  static String formatSales(int sales) {
    if (sales >= 1000) {
      return '${(sales / 1000).toStringAsFixed(1)}K';
    }
    return sales.toString();
  }
}
