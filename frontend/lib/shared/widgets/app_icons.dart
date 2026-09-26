import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static Widget dashboard({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="3" width="7" height="7"></rect>
          <rect x="14" y="3" width="7" height="7"></rect>
          <rect x="14" y="14" width="7" height="7"></rect>
          <rect x="3" y="14" width="7" height="7"></rect>
        </svg>''',
        size,
      );

  static Widget shipments({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="1" y="3" width="15" height="13"></rect>
          <polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon>
          <circle cx="5.5" cy="18.5" r="2.5"></circle>
          <circle cx="18.5" cy="18.5" r="2.5"></circle>
        </svg>''',
        size,
      );

  static Widget services({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <line x1="2" y1="12" x2="22" y2="12"></line>
          <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
        </svg>''',
        size,
      );

  static Widget notifications({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
          <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
        </svg>''',
        size,
      );

  static Widget wallet({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect>
          <line x1="1" y1="10" x2="23" y2="10"></line>
        </svg>''',
        size,
      );

  static Widget addresses({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <line x1="22" y1="12" x2="18" y2="12"></line>
          <line x1="6" y1="12" x2="2" y2="12"></line>
          <line x1="12" y1="6" x2="12" y2="2"></line>
          <line x1="12" y1="22" x2="12" y2="18"></line>
        </svg>''',
        size,
      );

  static Widget inviteEarn({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <line x1="12" y1="8" x2="12" y2="16"></line>
          <line x1="8" y1="12" x2="16" y2="12"></line>
        </svg>''',
        size,
      );

  static Widget helpCenter({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <circle cx="12" cy="12" r="4"></circle>
          <line x1="4.93" y1="4.93" x2="9.17" y2="9.17"></line>
          <line x1="14.83" y1="14.83" x2="19.07" y2="19.07"></line>
          <line x1="14.83" y1="9.17" x2="19.07" y2="4.93"></line>
          <line x1="4.93" y1="19.07" x2="9.17" y2="14.83"></line>
        </svg>''',
        size,
      );

  static Widget exportsArrow({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="19" x2="12" y2="5"></line>
          <polyline points="5 12 12 5 19 12"></polyline>
        </svg>''',
        size,
      );

  static Widget importsArrow({required Color color, double size = 18}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <polyline points="19 12 12 19 5 12"></polyline>
        </svg>''',
        size,
      );

  static Widget clock({required Color color, double size = 16}) =>
      _svg(
        '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="${_colorToHex(color)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <polyline points="12 6 12 12 16 14"></polyline>
        </svg>''',
        size,
      );

  static Widget globeCircle({double size = 48}) =>
      _svg(
        '''<svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <line x1="2" y1="12" x2="22" y2="12"></line>
          <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
        </svg>''',
        size,
      );

  static Widget _svg(String raw, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        raw,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
