window.LookforitMonetization = {
  enabled: true,
  adsense: {
    enabled: false,
    publisherId: "ca-pub-7363635746119645",
    autoAds: false,
    articleSlots: {
      aboveFold: "",
      midContent: "",
      endContent: ""
    },
    toolSlots: {
      aboveFold: "",
      midContent: "",
      endContent: ""
    }
  },
  tracking: {
    outboundClicks: true,
    ctaClicks: true,
    affiliateClicks: true,
    scrollDepth: true,
    engagement: true
  },
  utm: {
    source: "lookforit",
    medium: "affiliate",
    campaignByPageType: {
      tool: "toolpage",
      article: "article",
      default: "site"
    },
    contentMap: {
      stickybar: "stickybar",
      inline: "inlinecta",
      pricing_table: "pricingtable",
      popup: "popupcta",
      sidebar: "sidebarcta"
    }
  },
  affiliate: {
    autoMarkExternalAsSponsored: true,
    fallbackUrl: "/tools/",
    domains: [
      "impact.com",
      "partnerstack.com",
      "shareasale.com",
      "cj.com",
      "awin1.com",
      "hostinger.com",
      "digitalocean.com",
      "notion.so",
      "grammarly.com",
      "zapier.com"
    ],
    routing: {
      "ai-writing": {
        keywords: ["writing", "copy", "content", "blog", "jasper", "writesonic", "copy.ai"],
        urgency: "Free trial available",
        stickyText: "Write better content with AI writing tools",
        offers: [
          { name: "Jasper", network: "direct", url: "https://www.jasper.ai/" },
          { name: "Writesonic", network: "direct", url: "https://writesonic.com/" },
          { name: "Copy.ai", network: "direct", url: "https://www.copy.ai/" }
        ]
      },
      "seo": {
        keywords: ["seo", "keyword", "search", "semrush", "ahrefs", "surfer", "ranking"],
        urgency: "Limited-time deal",
        stickyText: "Compare the best SEO tools",
        offers: [
          { name: "Semrush", network: "direct", url: "https://www.semrush.com/" },
          { name: "Ahrefs", network: "direct", url: "https://ahrefs.com/" },
          { name: "Surfer SEO", network: "direct", url: "https://surferseo.com/" },
          { name: "Hostinger", network: "direct", url: "https://www.hostinger.com/" }
        ]
      },
      "design": {
        keywords: ["design", "canva", "envato", "creative market", "graphic", "ui"],
        urgency: "Save up to 40%",
        stickyText: "Level up your design stack quickly",
        offers: [
          { name: "Canva Pro", network: "direct", url: "https://www.canva.com/" },
          { name: "Envato", network: "direct", url: "https://elements.envato.com/" },
          { name: "Creative Market", network: "direct", url: "https://creativemarket.com/" }
        ]
      },
      "developer": {
        keywords: ["developer", "coding", "code", "copilot", "api", "git", "cursor"],
        urgency: "Free credits available",
        stickyText: "Ship faster with developer tools",
        offers: [
          { name: "DigitalOcean", network: "direct", url: "https://www.digitalocean.com/" },
          { name: "Hostinger", network: "direct", url: "https://www.hostinger.com/" },
          { name: "GitHub Copilot", network: "direct", url: "https://github.com/features/copilot" }
        ]
      },
      "resume": {
        keywords: ["resume", "job", "cv", "career", "interview", "linkedin"],
        urgency: "Hiring season boost",
        stickyText: "Build a better resume faster",
        offers: [
          { name: "Resume.io", network: "direct", url: "https://resume.io/" },
          { name: "Zety", network: "direct", url: "https://zety.com/" },
          { name: "LinkedIn Premium", network: "direct", url: "https://www.linkedin.com/premium" }
        ]
      },
      "ai-image": {
        keywords: ["image", "midjourney", "leonardo", "firefly", "art", "photo"],
        urgency: "Creator trial available",
        stickyText: "Create better AI visuals instantly",
        offers: [
          { name: "Midjourney", network: "direct", url: "https://www.midjourney.com/" },
          { name: "Leonardo AI", network: "direct", url: "https://app.leonardo.ai/" },
          { name: "Adobe Firefly", network: "direct", url: "https://www.adobe.com/products/firefly.html" }
        ]
      },
      "video": {
        keywords: ["video", "invideo", "veed", "pictory", "shorts", "editing"],
        urgency: "Free trial available",
        stickyText: "Turn scripts into videos faster",
        offers: [
          { name: "Pictory", network: "direct", url: "https://pictory.ai/" },
          { name: "InVideo", network: "direct", url: "https://invideo.io/" },
          { name: "VEED", network: "direct", url: "https://www.veed.io/" }
        ]
      },
      "productivity": {
        keywords: ["productivity", "notion", "grammarly", "zapier", "workflow", "automation"],
        urgency: "Save hours every week",
        stickyText: "Automate repetitive work today",
        offers: [
          { name: "Notion", network: "direct", url: "https://www.notion.so/product" },
          { name: "Grammarly", network: "direct", url: "https://www.grammarly.com/" },
          { name: "Zapier", network: "direct", url: "https://zapier.com/" }
        ]
      },
      "hosting": {
        keywords: ["hosting", "website builder", "wordpress", "vps", "domain"],
        urgency: "Get the cheapest hosting deal",
        stickyText: "Launch your site with reliable hosting",
        offers: [
          { name: "Hostinger", network: "direct", url: "https://www.hostinger.com/" },
          { name: "DigitalOcean", network: "direct", url: "https://www.digitalocean.com/" },
          { name: "Cloudways", network: "direct", url: "https://www.cloudways.com/" }
        ]
      },
      "default": {
        keywords: [],
        urgency: "Free trial available",
        stickyText: "Compare top tools and choose faster",
        offers: [
          { name: "Top Tools", network: "internal", url: "/tools/" }
        ]
      }
    }
  },
  leadMagnet: {
    enabled: true,
    title: "Get weekly AI workflow checklists",
    description: "Get templates, prompts, and practical workflows every week.",
    ctaText: "Get Checklist",
    targetUrl: "/contact.html"
  },
  leadScoring: {
    popupSubmit: 10,
    affiliateClick: 5,
    pricingTableClick: 7,
    returnVisit: 3,
    scroll90: 2
  },
  comparisonData: {
    "seo": [
      { tool: "Semrush", bestFor: "All-in-one SEO", freePlan: "Limited", startPrice: "$129/mo", keyFeatures: "Keyword tracking, audits" },
      { tool: "Ahrefs", bestFor: "Backlink research", freePlan: "No", startPrice: "$99/mo", keyFeatures: "Backlinks, keywords" },
      { tool: "Surfer SEO", bestFor: "Content optimization", freePlan: "Trial", startPrice: "$89/mo", keyFeatures: "SERP NLP editor" }
    ],
    "resume": [
      { tool: "Resume.io", bestFor: "Fast resume builder", freePlan: "Limited", startPrice: "$2.95 trial", keyFeatures: "ATS templates" },
      { tool: "Zety", bestFor: "Professional CV", freePlan: "Limited", startPrice: "$5.95 trial", keyFeatures: "Guided writing" },
      { tool: "LinkedIn Premium", bestFor: "Job networking", freePlan: "Trial", startPrice: "$39/mo", keyFeatures: "InMail, applicant insights" }
    ],
    "hosting": [
      { tool: "Hostinger", bestFor: "Low-cost hosting", freePlan: "No", startPrice: "$2.99/mo", keyFeatures: "Managed WordPress" },
      { tool: "DigitalOcean", bestFor: "Developer VPS", freePlan: "Credit", startPrice: "$4/mo", keyFeatures: "Cloud compute" },
      { tool: "Cloudways", bestFor: "Managed cloud", freePlan: "Trial", startPrice: "$11/mo", keyFeatures: "Managed stack" }
    ],
    "ai-writing": [
      { tool: "Jasper", bestFor: "Marketing teams", freePlan: "Trial", startPrice: "$49/mo", keyFeatures: "Brand voice" },
      { tool: "Writesonic", bestFor: "Long-form content", freePlan: "Yes", startPrice: "$16/mo", keyFeatures: "Article workflows" },
      { tool: "Copy.ai", bestFor: "Sales copy", freePlan: "Yes", startPrice: "$36/mo", keyFeatures: "Workflow templates" }
    ],
    "ai-image": [
      { tool: "Midjourney", bestFor: "Creative visuals", freePlan: "No", startPrice: "$10/mo", keyFeatures: "High-quality output" },
      { tool: "Leonardo AI", bestFor: "Game assets", freePlan: "Yes", startPrice: "$12/mo", keyFeatures: "Style control" },
      { tool: "Adobe Firefly", bestFor: "Brand-safe imagery", freePlan: "Credits", startPrice: "$4.99/mo", keyFeatures: "Adobe integration" }
    ]
  }
};
