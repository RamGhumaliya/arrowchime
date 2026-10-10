/// Placeholder SVG sprites for the mechanic objects (`docs/10` §8). Obvious
/// stand-ins: flat 3-tone shapes lit from the top-left.
abstract final class Svgs {
  static const String _header =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" '
      'width="128" height="128">\n'
      '  <!-- PLACEHOLDER: replace with the final artwork from the artist. -->\n';

  static String forName(String name) => switch (name) {
    'rotator_ring' => _rotatorRing,
    'portal_ring' => _portalRing,
    'chain_link' => _chainLink,
    'gate_amber' => _gate('F2A33A', 'circle'),
    'gate_jade' => _gate('2FB58A', 'triangle'),
    'gate_rose' => _gate('E86A92', 'square'),
    'gate_azure' => _gate('4D9FE8', 'diamond'),
    _ => throw ArgumentError.value(name, 'name', 'unknown mechanic sprite'),
  };

  static const String _rotatorRing =
      '$_header'
      '  <circle cx="64" cy="64" r="52" fill="#8A6A1F"/>\n'
      '  <circle cx="64" cy="64" r="48" fill="#C9952A"/>\n'
      '  <circle cx="64" cy="64" r="32" fill="#121A2B" fill-opacity="0.25"/>\n'
      '  <path d="M22 46 A48 48 0 0 1 64 18" fill="none" stroke="#FFD15C" '
      'stroke-width="6" stroke-linecap="round"/>\n'
      '  <path d="M64 104 L84 84 L44 84 Z" fill="#8A6A1F"/>\n'
      '</svg>\n';

  static const String _portalRing =
      '$_header'
      '  <circle cx="64" cy="64" r="54" fill="#0E7D72"/>\n'
      '  <circle cx="64" cy="64" r="50" fill="#19B3A3"/>\n'
      '  <circle cx="64" cy="64" r="30" fill="#121A2B" fill-opacity="0.45"/>\n'
      '  <circle cx="64" cy="64" r="20" fill="none" stroke="#6EC6FF" '
      'stroke-width="4" stroke-dasharray="10 8"/>\n'
      '  <path d="M20 44 A50 50 0 0 1 58 16" fill="none" stroke="#FFFFFF" '
      'stroke-opacity="0.6" stroke-width="5" stroke-linecap="round"/>\n'
      '</svg>\n';

  static const String _chainLink =
      '$_header'
      '  <rect x="14" y="40" width="64" height="48" rx="24" fill="none" '
      'stroke="#8A6A1F" stroke-width="12"/>\n'
      '  <rect x="50" y="40" width="64" height="48" rx="24" fill="none" '
      'stroke="#C9952A" stroke-width="12"/>\n'
      '  <path d="M26 56 A18 18 0 0 1 44 48" fill="none" stroke="#FFD15C" '
      'stroke-width="4" stroke-linecap="round"/>\n'
      '</svg>\n';

  /// A lacquered arch with a colour-blind symbol on a brass badge.
  static String _gate(String hex, String symbol) {
    final glyph = switch (symbol) {
      'circle' => '<circle cx="64" cy="76" r="12" fill="#$hex"/>',
      'triangle' => '<path d="M64 62 L78 88 L50 88 Z" fill="#$hex"/>',
      'square' => '<rect x="52" y="64" width="24" height="24" fill="#$hex"/>',
      _ => '<path d="M64 62 L78 76 L64 90 L50 76 Z" fill="#$hex"/>',
    };
    return '$_header'
        '  <path d="M14 116 V52 a50 50 0 0 1 100 0 V116 Z" fill="#6B4A2B"/>\n'
        '  <path d="M20 112 V52 a44 44 0 0 1 88 0 V112 Z" fill="#8F6538"/>\n'
        '  <path d="M20 52 a44 44 0 0 1 28 -40" fill="none" stroke="#B88A55" '
        'stroke-width="5" stroke-linecap="round"/>\n'
        '  <circle cx="64" cy="76" r="22" fill="#C9952A"/>\n'
        '  $glyph\n'
        '</svg>\n';
  }
}
