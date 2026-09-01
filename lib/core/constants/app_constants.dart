const Map<String, Map<String, List<String>>> locationData = {
  'Maharashtra': {
    'Pune': ['Khed', 'Manchar', 'Someshwar', 'Baramati', 'Khandala'],
    'Nashik': ['Ozar', 'Sinnar', 'Kalwan', 'Yeola', 'Pimplas'],
    'Nagpur': ['Umred', 'Katol', 'Kamthi', 'Kalmeshwar', 'Saoner'],
  },
  'Punjab': {
    'Ludhiana': ['Gill', 'Lalton', 'Mullanpur', 'Dakha', 'Sahnewal'],
    'Amritsar': ['Majitha', 'Jandiala', 'Rayya', 'Rajasansi', 'Attari'],
    'Patiala': ['Nabha', 'Rajpura', 'Samana', 'Patran', 'Sanaur'],
  },
  'Karnataka': {
    'Bangalore': ['Kengeri', 'Yelahanka', 'Whitefield', 'Sarjapur', 'Nelamangala'],
    'Mysore': ['Nanjangud', 'Hunsur', 'T Narasipura', 'KR Nagar', 'Periyapatna'],
    'Belgaum': ['Gokak', 'Chikodi', 'Athani', 'Raybag', 'Hukkeri'],
  },
  'Gujarat': {
    'Anand': ['Mogar', 'Karamsad', 'Borsad', 'Petlad', 'Khambhat'],
    'Mehsana': ['Visnagar', 'Kadi', 'Unjha', 'Vadnagar', 'Becharaji'],
    'Rajkot': ['Gondal', 'Jetpur', 'Jasdan', 'Dhoraji', 'Morbi'],
  },
  'Uttar Pradesh': {
    'Meerut': ['Mawana', 'Sardhana', 'Hastinapur', 'Kithaur', 'Daurala'],
    'Lucknow': ['Malihabad', 'Bakshi Ka Talab', 'Gosainganj', 'Kakori', 'Mohanlalganj'],
    'Varanasi': ['Pindra', 'Cholapur', 'Harahua', 'Kashi Vidyapeeth', 'Arajiline'],
  },
  'Madhya Pradesh': {
    'Indore': ['Mhow', 'Depalpur', 'Sanwer', 'Hatod', 'Runji'],
    'Bhopal': ['Berasia', 'Kolar', 'Phanda', 'Huzur', 'Misrod'],
    'Jabalpur': ['Sihora', 'Patan', 'Shahpura', 'Kundam', 'Panagar'],
  },
};

/// Gemini API Key configuration for AI Crop Scan (Free Tier)
/// Pass via `--dart-define=GEMINI_API_KEY=your_key_here`
const String geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

