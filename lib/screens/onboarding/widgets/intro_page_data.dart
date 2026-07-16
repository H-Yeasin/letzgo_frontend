class IntroPageData {
  final String eyebrow;
  final String titleTop;
  final String titleGlow;
  final String body;

  const IntroPageData({
    required this.eyebrow,
    required this.titleTop,
    required this.titleGlow,
    required this.body,
  });
}

const introPages = [
  IntroPageData(
    eyebrow: 'RIDE TOGETHER',
    titleTop: 'No drivers.',
    titleGlow: 'Just riders.',
    body:
        'Host a ride one day, hop into one the next — '
        'you decide every trip.',
  ),
  IntroPageData(
    eyebrow: 'PING NEARBY',
    titleTop: 'Ping riders',
    titleGlow: 'going your way',
    body:
        'Share your route and find fellow commuters '
        'heading in the same direction.',
  ),
  IntroPageData(
    eyebrow: 'SPLIT THE FARE',
    titleTop: 'Half the fare,',
    titleGlow: 'same ride',
    body:
        'Split the cost of every trip. The more you '
        'share, the more you save.',
  ),
  IntroPageData(
    eyebrow: 'RIDE SAFE',
    titleTop: 'Safety is',
    titleGlow: 'built in',
    body:
        'Verified riders, community ratings, and '
        'gender preferences — set per ride, not per profile.',
  ),
];
