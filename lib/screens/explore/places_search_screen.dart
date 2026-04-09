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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                color: colors.background.withValues(alpha: 0.7),
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
                          backgroundColor: colors.glassSurface,
                          shape: const CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassBox(
                          borderRadius: AppRadius.pill,
                          padding: EdgeInsets.zero,
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
                
                // Loading indicator
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: colors.glassBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                      ),
                    ),
                  ),

                // Results List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) => Divider(
                      color: colors.divider,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final req = _suggestions[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.glassSurface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on_rounded, color: colors.textSecondary, size: 18),
                        ),
                        title: Text(
                          req.mainText,
                          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: req.secondaryText.isNotEmpty ? Text(
                          req.secondaryText,
                          style: AppTextStyles.caption(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ) : null,
                        onTap: () => _selectPlace(req),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
