import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/services/location_service.dart';

class PlacesSearchScreen extends StatefulWidget {
  final String hint;
  final String? initialValue;

  const PlacesSearchScreen({
    super.key,
    required this.hint,
    this.initialValue,
  });

  @override
  State<PlacesSearchScreen> createState() => _PlacesSearchScreenState();
}

class _PlacesSearchScreenState extends State<PlacesSearchScreen> {
  late TextEditingController _searchCtrl;
  final FocusNode _focusNode = FocusNode();
  final LocationService _locationService = LocationService();
  
  List<PlaceSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _placesApiUnavailable = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialValue);
    _focusNode.requestFocus();
    _locationService.refreshSessionToken();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await _locationService.getSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _placesApiUnavailable = _locationService.isPlacesApiDisabled;
          _isLoading = false;
        });
      }
    });
  }

  void _selectPlace(PlaceSuggestion suggestion) async {
    setState(() => _isLoading = true);
    
    final details = await _locationService.getPlaceDetails(suggestion.placeId);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (details != null) {
        Navigator.of(context).pop(details);
      } else {
        // Fallback if details fail, just return the name
        Navigator.of(context).pop(PlaceDetails(
          lat: 0, 
          lng: 0, 
          name: suggestion.mainText, 
          address: suggestion.secondaryText,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final hasQuery = _searchCtrl.text.trim().isNotEmpty;
    final showEmptyState = !_isLoading && !_placesApiUnavailable && hasQuery && _suggestions.isEmpty;

    final maxSuggestionsHeight = MediaQuery.of(context).size.height * 0.56;
    final showSuggestionsList =
      !_placesApiUnavailable && !showEmptyState && _suggestions.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Clean background wash to keep focus on search results.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.background,
                    colors.backgroundElevated.withValues(alpha: 0.97),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlue.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -110,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSky.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Search Bar Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.backgroundElevated.withValues(alpha: 0.95),
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(
                            color: colors.glassBorderSubtle,
                            width: 1,
                          ),
                          shape: const CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassBox(
                          borderRadius: AppRadius.pill,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: TextField(
                            controller: _searchCtrl,
                            focusNode: _focusNode,
                            onChanged: _onSearchChanged,
                            style: AppTextStyles.body(context),
                            decoration: InputDecoration(
                              hintText: widget.hint,
                              hintStyle: AppTextStyles.bodySecondary(context),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: colors.textSecondary, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close_rounded, size: 18, color: colors.textTertiary),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                  child: Row(
                    children: [
                      Text(
                        hasQuery ? 'Suggestions' : 'Start typing to search places',
                        style: AppTextStyles.caption(context).copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Loading indicator
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(99),
                        backgroundColor: colors.glassBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                      ),
                    ),
                  ),

                // Results List
                if (_placesApiUnavailable)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: GlassBox(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.key_off_rounded,
                                color: colors.textSecondary,
                                size: 26,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Places search is temporarily unavailable (API key expired). Enter location manually or renew the API key.',
                                style: AppTextStyles.bodySecondary(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else if (showEmptyState)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: GlassBox(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.travel_explore_rounded,
                                color: colors.textSecondary,
                                size: 28,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No matches found. Try a more specific road, area, or city.',
                                style: AppTextStyles.bodySecondary(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else if (showSuggestionsList)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxSuggestionsHeight),
                        child: GlassBox(
                          padding: EdgeInsets.zero,
                          borderRadius: 18,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            separatorBuilder: (context, index) => Divider(
                              color: colors.divider,
                              height: 1,
                              indent: 56,
                              endIndent: 12,
                            ),
                            itemBuilder: (context, index) {
                              final req = _suggestions[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _selectPlace(req),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(9),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentBlue.withValues(alpha: 0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            color: AppColors.accentBlue,
                                            size: 17,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                req.mainText,
                                                style: AppTextStyles.body(context).copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (req.secondaryText.isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  req.secondaryText,
                                                  style: AppTextStyles.caption(context),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 19,
                                          color: colors.textTertiary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
