class JourneyBookData {
  final String title;
  final String author;
  final String coverUrl;
  final String whyThisBook;
  final String thematicConnections;
  final String keyInsights;
  final String collectionContext;
  final String curatorQuote;

  JourneyBookData({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.whyThisBook,
    required this.thematicConnections,
    required this.keyInsights,
    required this.collectionContext,
    required this.curatorQuote,
  });

  static List<JourneyBookData> getJourneyBooks() {
    return [
      JourneyBookData(
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        coverUrl: "https://picsum.photos/seed/gatsby1920/800/1200.jpg",
        whyThisBook: "The Great Gatsby represents the pinnacle of American literary modernism, capturing the essence of the Jazz Age with unparalleled elegance and precision. Fitzgerald's masterpiece serves as both a celebration and critique of the American Dream, making it essential reading for understanding the cultural landscape of 20th-century America.",
        thematicConnections: "This exploration of illusion versus reality sets the foundation for our collection's theme of 'Perception and Truth in American Literature.' Gatsby's green light becomes a metaphor for the elusive nature of happiness that echoes throughout the works that follow.",
        keyInsights: "Pay attention to Fitzgerald's masterful use of color symbolism—green for hope, yellow for corruption, white for illusion. The narrative structure itself, with Nick's unreliable narration, invites us to question how stories shape our understanding of truth.",
        collectionContext: "Opening with Gatsby establishes our journey's central question: How do we distinguish between authentic experience and carefully constructed narratives? This tension will guide us through the entire collection.",
        curatorQuote: "Gatsby believed in the green light, the orgastic future that year by year recedes before us. It eluded us then, but that's no matter—tomorrow we will run faster, stretch out our arms farther...",
      ),
      JourneyBookData(
        title: "To Kill a Mockingbird",
        author: "Harper Lee",
        coverUrl: "https://picsum.photos/seed/mockingbird1960/800/1200.jpg",
        whyThisBook: "Harper Lee's novel transcends its Southern Gothic setting to become a universal meditation on moral courage and the loss of innocence. Through Scout's eyes, we witness the complex interplay between justice and prejudice, making this work indispensable for understanding American moral literature.",
        thematicConnections: "Where Gatsby explored the corruption of the American Dream, Mockingbird examines its application in the face of systemic injustice. Both novels question whether American ideals can survive real-world testing.",
        keyInsights: "Lee's dual narrative structure—Scout's childhood innocence versus adult reflection—creates a powerful commentary on moral development. The symbolism of the mockingbird itself asks us to consider who in our society deserves protection.",
        collectionContext: "Following Gatsby's exploration of personal truth, Mockingbird expands our inquiry to societal truth. How do communities construct narratives that either uphold or destroy justice?",
        curatorQuote: "You never really understand a person until you consider things from his point of view... until you climb into his skin and walk around in it.",
      ),
      JourneyBookData(
        title: "1984",
        author: "George Orwell",
        coverUrl: "https://picsum.photos/seed/nineteen84/800/1200.jpg",
        whyThisBook: "Orwell's dystopian vision has become increasingly prophetic, making it essential reading for understanding the relationship between truth, power, and language. The novel's exploration of how authoritarian regimes manipulate reality speaks directly to contemporary concerns about information control.",
        thematicConnections: "While our previous books examined truth through personal and social lenses, 1984 presents truth as a political construct. The novel's concepts of 'Newspeak' and 'doublethink' extend our collection's inquiry into how language shapes reality.",
        keyInsights: "Orwell's warning about the corruption of language is particularly relevant today. Notice how the Party doesn't just control actions—it controls thought itself by eliminating the words needed for rebellion. The relationship between Winston and Julia serves as a powerful counterpoint to state control.",
        collectionContext: "This work completes our trilogy of truth-seeking narratives, moving from personal delusion (Gatsby) to social injustice (Mockingbird) to political manipulation (1984). Together, they map the terrain of truth in modern society.",
        curatorQuote: "War is peace. Freedom is slavery. Ignorance is strength.",
      ),
      JourneyBookData(
        title: "Beloved",
        author: "Toni Morrison",
        coverUrl: "https://picsum.photos/seed/beloved1987/800/1200.jpg",
        whyThisBook: "Morrison's Pulitzer Prize-winning novel represents the pinnacle of American magical realism, blending historical trauma with supernatural elements to explore the lasting impact of slavery. This work is crucial for understanding how American literature grapples with its most painful truths.",
        thematicConnections: "Beloved introduces a new dimension to our exploration of truth—the truth that refuses to be buried. Where 1984 showed how truth can be manufactured, Beloved demonstrates how some truths demand to be acknowledged, regardless of the cost.",
        keyInsights: "Morrison's use of the supernatural as metaphor for historical trauma creates a powerful narrative strategy. The ghost of Beloved represents both individual guilt and collective memory. Notice how the novel's structure itself—fragmented, non-linear—mirrors the experience of trauma.",
        collectionContext: "This work expands our collection beyond questions of perception to include questions of memory and historical responsibility. How do societies reconcile with truths they would rather forget?",
        curatorQuote: "Freeing yourself was one thing, claiming ownership of that freed self was another.",
      ),
      JourneyBookData(
        title: "The Catcher in the Rye",
        author: "J.D. Salinger",
        coverUrl: "https://picsum.photos/seed/catcher1951/800/1200.jpg",
        whyThisBook: "Salinger's iconic novel captures the adolescent struggle with authenticity in a world perceived as increasingly phony. Holden Caulfield's voice has defined generations of readers' understanding of teenage alienation and the search for genuine connection.",
        thematicConnections: "Following Beloved's exploration of historical truth, Catcher turns to personal authenticity. Where Sethe couldn't escape the past, Holden can't escape his present perception of universal phoniness—both are trapped by different kinds of truth.",
        keyInsights: "Holden's narrative voice—rambling, contradictory, vulnerable—creates a powerful study in unreliable narration. The symbolism of the catcher in the rye represents an impossible desire to preserve innocence in a corrupt world. Notice how Salinger uses dialogue to reveal character.",
        collectionContext: "This work brings our collection full circle, returning to the question first raised by Gatsby: Can we find authenticity in a world of performance? Holden's answer suggests perhaps not, but the search itself matters.",
        curatorQuote: "The mark of the immature man is that he wants to die nobly for a cause, while the mark of the mature man is that he wants to live humbly for one.",
      ),
    ];
  }
}