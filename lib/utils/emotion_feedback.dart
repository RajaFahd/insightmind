enum Emotion {
  happy,
  sad,
  angry,
  fearful,
  neutral,
  surprised,
}

class EmotionFeedback {
  static const Map<Emotion, String> feedbackMessages = {
    Emotion.happy: "Kamu terlihat bahagia hari ini 😊",
    Emotion.sad: "Sepertinya kamu sedang sedih, istirahat dulu yuk...",
    Emotion.angry: "Kamu tampak tegang, coba tarik napas perlahan.",
    Emotion.fearful: "Tenang ya, semuanya akan baik-baik saja.",
    Emotion.neutral: "Ekspresimu terlihat netral.",
    Emotion.surprised: "Kamu tampak terkejut, ada yang terjadi?",
  };

  static String getFeedback(Emotion emotion) {
    return feedbackMessages[emotion] ?? "Ekspresi tidak dikenali.";
  }
}