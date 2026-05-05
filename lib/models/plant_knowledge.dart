class PlantKnowledge {
  final String question;
  final String answer;
  final List<String> keywords;

  PlantKnowledge({
    required this.question,
    required this.answer,
    required this.keywords,
  });
}

class PlantKnowledgeBase {
  final List<PlantKnowledge> _knowledgeBase = [
    PlantKnowledge(
      question: "Northern Leaf Blight",
      answer:
          "Northern Leaf Blight husababishwa na fungus Exserohilum turcicum.\n\n"
          "Dalili:\n"
          "• Matuta marefu ya kijivu kwenye majani\n"
          "• Maeneo yana umbo la sigara\n"
          "• Huanza kwenye majani ya chini\n\n"
          "Matibabu:\n"
          "• Tumia mbegu zinazostahimili ugonjwa\n"
          "• Paka dawa za fungicides (Azoxystrobin, Pyraclostrobin)\n"
          "• Fanya mzunguko wa mazao (crop rotation)\n"
          "• Ondoa mabaki ya mimea baada ya mavuno",
      keywords: ["blight", "northern", "leaf blight", "ugonjwa wa majani"],
    ),
    PlantKnowledge(
      question: "Gray Leaf Spot",
      answer:
          "Gray Leaf Spot (Cercospora zeae-maydis)\n\n"
          "Dalili:\n"
          "• Matuta madogo ya kijivu\n"
          "• Umbo la mstatili\n"
          "• Huonekana karibu na mishipa ya jani\n\n"
          "Matibabu:\n"
          "• Fungicides: Strobilurin au Triazole\n"
          "• Panda aina zinazostahimili\n"
          "• Usilime mahindi mwaka mwaka kwenye shamba moja\n"
          "• Weka mbolea ya potasiamu",
      keywords: ["gray leaf", "leaf spot", "grey leaf", "madoa ya majani"],
    ),
    PlantKnowledge(
      question: "Maize Rust",
      answer:
          "Common Rust (Puccinia sorghi)\n\n"
          "Dalili:\n"
          "• Mabaka ya rangi ya kutu (brown/orange)\n"
          "• Huanza kuonekana kwenye majani ya juu\n"
          "• Husababisha majani kukauka mapema\n\n"
          "Matibabu:\n"
          "• Fungicides: Propiconazole, Pyraclostrobin\n"
          "• Panda aina za mahindi zinazostahimili kutu\n"
          "• Panda mapema ili kuepuka msimu wa kutu\n"
          "• Ondoa majani yaliyoathirika",
      keywords: ["rust", "kutu", "brown spots", "orange spots"],
    ),
    PlantKnowledge(
      question: "Fertilizer Application",
      answer:
          "Ratiba ya Mbolea kwa Mahindi:\n\n"
          "Kabla ya Kupanda:\n"
          "• DAP au NPK 23:23:0 (150kg kwa hekta)\n\n"
          "Wiki 3-4 baada ya kupanda:\n"
          "• CAN (100kg kwa hekta)\n\n"
          "Wiki 6-8 baada ya kupanda:\n"
          "• Urea (50kg kwa hekta)\n\n"
          "Vidokezo:\n"
          "• Fanya upimaji wa udongo kwanza\n"
          "• Tumia mbolea wakati wa kunyesha au umwagiliaji\n"
          "• Usichanganye mbolea tofauti kwenye shimo moja",
      keywords: ["fertilizer", "mbolea", "npk", "dap", "can", "urea"],
    ),
    PlantKnowledge(
      question: "Watering Schedule",
      answer:
          "Umwagiliaji wa Mahindi:\n\n"
          "Hatua muhimu za maji:\n"
          "• Kuota (siku 0-10): Udongo uwe unyevu\n"
          "• Ukuaji (siku 20-40): Maji ya wastani\n"
          "• Kuchua na Maua (HATUA MUHIMU): Usikose maji!\n"
          "• Kujaza punje (siku 60-90): Maji ya kutosha\n\n"
          "Kiasi:\n"
          "• Mahindi yanahitaji 500-600mm maji kwa msimu\n"
          "• Umwagiliaji kila siku 5-7 (wakati wa ukuaji)\n"
          "• Umwagiliaji kila siku 3-4 (wakati wa kuchua)",
      keywords: ["water", "maji", "irrigation", "umwagiliaji", "kunyesha"],
    ),
    PlantKnowledge(
      question: "Planting Time",
      answer:
          "Nyakati bora za kupanda mahindi Tanzania:\n\n"
          "Msimu wa Vuli (Machi - Mei):\n"
          "• Huanza kupanda baada ya mvua za kwanza\n"
          "• Inafaa kwa maeneo mengi\n\n"
          "Msimu wa Masika (Oktoba - Desemba):\n"
          "• Kwa maeneo yenye misimu miwili\n\n"
          "Joto la udongo:\n"
          "• Lazima iwe 10°C (50°F) kwa kina cha 5cm\n\n"
          "Kina cha kupanda:\n"
          "• Udongo mzito: 4-5cm\n"
          "• Udongo mwepesi: 5-7cm",
      keywords: ["planting", "kupanda", "when to plant", "msimu", "season"],
    ),
  ];

  Future<String> getResponse(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    String lowerQuery = query.toLowerCase();

    // Check for exact matches first
    for (var knowledge in _knowledgeBase) {
      if (lowerQuery.contains(knowledge.question.toLowerCase())) {
        return knowledge.answer;
      }
    }

    // Check for keywords
    for (var knowledge in _knowledgeBase) {
      for (var keyword in knowledge.keywords) {
        if (lowerQuery.contains(keyword.toLowerCase())) {
          return knowledge.answer;
        }
      }
    }

    // Default response for unknown queries
    return "🌽 **Ninaweza kukusaidia na:**\n\n"
        "**Magonjwa ya Mahindi:**\n"
        "• Northern Leaf Blight\n"
        "• Gray Leaf Spot\n"
        "• Maize Rust\n\n"
        "**Matibabu na Dawa:**\n"
        "• Fungicides\n"
        "• Mbegu zinazostahimili\n\n"
        "**Kilimo Bora:**\n"
        "• Mbolea na ratiba yake\n"
        "• Umwagiliaji na maji\n"
        "• Nyakati za kupanda\n\n"
        "_Uliza swali maalum kuhusu mahindi yako!_";
  }

  List<PlantKnowledge> getAllKnowledge() {
    return _knowledgeBase;
  }
}
