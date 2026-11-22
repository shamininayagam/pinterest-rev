import '../model/author_model.dart';
import '../model/board_model.dart';
import '../model/comment_model.dart';
import '../model/pin_model.dart';

const List<String> kCategories = [
  'All',
  'Architecture',
  'Interior',
  'Tech',
  'Coffee',
  'Photography',
  'Travel',
  'Art',
];

final List<Board> kSeedBoards = [
  Board(
    id: 'board-1',
    name: 'Design & Architecture',
    description: 'Clean lines, brutalism, and minimalist spaces',
    coverPinId: 'pin-1',
    isPrivate: false,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  Board(
    id: 'board-2',
    name: 'Tokyo Vibes',
    description: 'Cyberpunk, neon nights, and street aesthetics',
    coverPinId: 'pin-3',
    isPrivate: false,
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  Board(
    id: 'board-3',
    name: 'Minimalist Workspaces',
    description: 'Cozy desk setups, mechanical keyboards, and ambient light',
    coverPinId: 'pin-5',
    isPrivate: false,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Board(
    id: 'board-4',
    name: 'Coffee & Cafes',
    description: 'Third-wave coffee spots and artisanal latte art',
    coverPinId: 'pin-8',
    isPrivate: false,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Board(
    id: 'board-5',
    name: 'Personal Inspiration',
    description: 'Private moodboard for upcoming projects',
    coverPinId: 'pin-11',
    isPrivate: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

final List<Pin> kSeedPins = [
  Pin(
    id: 'pin-1',
    title: 'Brutalist Concrete Pavilion by the Ocean',
    description:
        'Striking cantilevered concrete structure framing the Pacific sunset. Exposed aggregate finish and minimalist glass railings.',
    imageUrl:
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.5,
    dominantColor: '#8a8b8c',
    author: const Author(
      name: 'Elena Rostova',
      handle: 'erostova',
      avatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://archdaily.com/concrete-ocean-pavilion',
    boardId: 'board-1',
    category: 'Architecture',
    likesCount: 2420,
    tags: ['Architecture', 'Brutalism', 'Concrete', 'Minimalist', 'Interior'],
    comments: [
      const Comment(
        id: 'c1',
        author: 'Mark Chen',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
        text: 'The natural lighting through those roof slits is sublime!',
        time: '2 hours ago',
      ),
      const Comment(
        id: 'c2',
        author: 'Sophie Laurent',
        avatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
        text: 'Where is this located? Adding to my dream travel list.',
        time: '1 day ago',
      ),
    ],
  ),
  Pin(
    id: 'pin-2',
    title: 'Matte Black Ceramic Pour-Over Set',
    description:
        'Handcrafted stoneware dripper with double-walled carafe. Perfect thermal retention for morning pour-overs.',
    imageUrl:
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.25,
    dominantColor: '#2b2a28',
    author: const Author(
      name: 'Kento Studio',
      handle: 'kentostudio',
      avatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://kento.design/pour-over',
    boardId: 'board-4',
    category: 'Coffee',
    likesCount: 1540,
    tags: ['Coffee', 'Ceramics', 'Craft', 'Kitchen', 'Minimalist'],
    comments: [
      const Comment(
        id: 'c3',
        author: 'Liam Wright',
        avatar:
            'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80',
        text: 'Using this daily with Ethiopia Yirgacheffe beans. Absolute game changer.',
        time: '3 days ago',
      ),
    ],
  ),
  Pin(
    id: 'pin-3',
    title: 'Rainy Shibuya Crossing at Midnight',
    description:
        'Reflections of neon billboards on wet asphalt. Captured with 35mm f/1.4 lens in Tokyo.',
    imageUrl:
        'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.7,
    dominantColor: '#1a1f36',
    author: const Author(
      name: 'Kenji Sato',
      handle: 'kenji_lens',
      avatar:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://500px.com/photo/tokyo-night-rain',
    boardId: 'board-2',
    category: 'Photography',
    likesCount: 8930,
    tags: ['Tokyo', 'Photography', 'Night', 'Cyberpunk', 'Rain', 'Street'],
    comments: [
      const Comment(
        id: 'c4',
        author: 'Aoi Tanaka',
        avatar:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=150&q=80',
        text: 'Incredible mood and color grading!',
        time: '4 hours ago',
      ),
    ],
  ),
  Pin(
    id: 'pin-4',
    title: 'Warm Scandinavian Living Room with Oak Bookshelves',
    description:
        'Floor-to-ceiling custom joinery, boucle sofa, and mid-century walnut lounge chair bathed in morning sunlight.',
    imageUrl:
        'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.35,
    dominantColor: '#d6c6b4',
    author: const Author(
      name: 'Astrid Lindgren',
      handle: 'nordichome',
      avatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://nordicliving.se/oak-interiors',
    boardId: 'board-1',
    category: 'Interior',
    likesCount: 4210,
    tags: ['Interior', 'Scandinavian', 'Woodworking', 'LivingRoom', 'Design'],
    comments: const [],
  ),
  Pin(
    id: 'pin-5',
    title: 'Zero-Distraction Ultrawide Workspace',
    description:
        'Custom walnut butcher block desk with hidden cable management, warm lightbar, and 40-inch curved display.',
    imageUrl:
        'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.45,
    dominantColor: '#3d3835',
    author: const Author(
      name: 'Alex Rivera',
      handle: 'setupvault',
      avatar:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://deskspace.io/alex-setup',
    boardId: 'board-3',
    category: 'Tech',
    likesCount: 6512,
    tags: ['Tech', 'Workspace', 'DeskSetup', 'Productivity', 'Minimalist'],
    comments: [
      const Comment(
        id: 'c5',
        author: 'David Kim',
        avatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
        text: 'What is that screen bar brand?',
        time: '1 day ago',
      ),
    ],
  ),
  Pin(
    id: 'pin-6',
    title: 'Emerald Green Velvet Armchair & Monstera',
    description:
        'Botanical indoor sanctuary with vintage brass reading lamp and potted houseplants.',
    imageUrl:
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.6,
    dominantColor: '#203d29',
    author: const Author(
      name: 'Chloe Dubois',
      handle: 'chloe_green',
      avatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://botanicalspaces.fr',
    boardId: 'board-1',
    category: 'Interior',
    likesCount: 3104,
    tags: ['Interior', 'Plants', 'Monstera', 'Vintage', 'Cozy'],
    comments: const [],
  ),
  Pin(
    id: 'pin-7',
    title: 'Akihabara Neon Alleyways',
    description:
        'Dense layered anime billboards and retro arcade signs glowing after dark in Tokyo.',
    imageUrl:
        'https://images.unsplash.com/photo-1542051841857-5f90071e7989?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.55,
    dominantColor: '#4b1d3f',
    author: const Author(
      name: 'Kenji Sato',
      handle: 'kenji_lens',
      avatar:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://kenjisato.photography/akiba',
    boardId: 'board-2',
    category: 'Photography',
    likesCount: 5420,
    tags: ['Tokyo', 'Neon', 'Cyberpunk', 'Travel', 'Japan'],
    comments: const [],
  ),
  Pin(
    id: 'pin-8',
    title: 'Matcha Foam Cloud Latte with Oat Milk',
    description:
        'Ceremonial grade Uji matcha layered over velvety microfoam in handcrafted fluted glassware.',
    imageUrl:
        'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.4,
    dominantColor: '#70834c',
    author: const Author(
      name: 'Hana Mori',
      handle: 'hanamatcha',
      avatar:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://hanamatcha.com/recipes/cloud-latte',
    boardId: 'board-4',
    category: 'Coffee',
    likesCount: 7810,
    tags: ['Coffee', 'Matcha', 'Recipe', 'Cafe', 'Drink'],
    comments: [
      const Comment(
        id: 'c7',
        author: 'Jessica Day',
        avatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
        text: 'Made this this morning, texture is unreal!',
        time: '6 hours ago',
      ),
    ],
  ),
  Pin(
    id: 'pin-9',
    title: 'Alpine Cabin Overlooking Dolomites Peaks',
    description:
        'A-frame larch wood architecture nestled against dramatic jagged limestone needles during golden hour.',
    imageUrl:
        'https://images.unsplash.com/photo-1510798831971-661eb04b3739?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.65,
    dominantColor: '#6e7060',
    author: const Author(
      name: 'Marco Rossi',
      handle: 'alpine_routes',
      avatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://dolomites.travel/alps-cabin',
    boardId: 'board-1',
    category: 'Travel',
    likesCount: 11200,
    tags: ['Travel', 'Mountains', 'Cabin', 'Architecture', 'Nature'],
    comments: const [],
  ),
  Pin(
    id: 'pin-10',
    title: 'Custom 65% Mechanical Keyboard Build',
    description:
        'Anodized burgundy aluminum case, lubed linear switches, and retro dye-sub PBT keycaps on brass plate.',
    imageUrl:
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.3,
    dominantColor: '#4a282b',
    author: const Author(
      name: 'Keycult Fan',
      handle: 'customclacks',
      avatar:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://reddit.com/r/MechanicalKeyboards',
    boardId: 'board-3',
    category: 'Tech',
    likesCount: 4890,
    tags: ['Tech', 'Keyboard', 'DeskSetup', 'Mechanical', 'Gadgets'],
    comments: const [],
  ),
  Pin(
    id: 'pin-11',
    title: 'Abstract Organic Clay Sculptures & Ceramics',
    description:
        'Wabi-sabi unglazed terracotta vessels casting deep geometric shadows in gallery setting.',
    imageUrl:
        'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.5,
    dominantColor: '#a67258',
    author: const Author(
      name: 'Camilla Gomez',
      handle: 'camilla_art',
      avatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://camillaceramics.com',
    boardId: 'board-5',
    category: 'Art',
    likesCount: 1980,
    tags: ['Art', 'Sculpture', 'Ceramics', 'Terracotta', 'WabiSabi'],
    comments: const [],
  ),
  Pin(
    id: 'pin-12',
    title: 'Traditional Kyoto Tea House Rock Garden',
    description:
        'Carefully raked granite gravel patterns and mossy boulders under weeping Japanese maple leaves.',
    imageUrl:
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80',
    aspectRatio: 1.45,
    dominantColor: '#3f4937',
    author: const Author(
      name: 'Kenji Sato',
      handle: 'kenji_lens',
      avatar:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
    ),
    link: 'https://kyotoculture.jp/zen-gardens',
    boardId: 'board-2',
    category: 'Travel',
    likesCount: 6310,
    tags: ['Japan', 'Kyoto', 'Zen', 'Garden', 'Travel', 'Peaceful'],
    comments: const [],
  ),
];
