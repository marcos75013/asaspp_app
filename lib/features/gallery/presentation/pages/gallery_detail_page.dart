import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/widgets/member_avatar.dart';
import '../../../user/data/profile_updates.dart';
import '../../data/models/gallery_model.dart';
import '../../data/models/photo_discussion.dart';
import '../../data/services/photo_interactions_api_service.dart';

class GalleryDetailPage extends StatefulWidget {
  final GalleryModel gallery;

  const GalleryDetailPage({super.key, required this.gallery});

  @override
  State<GalleryDetailPage> createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  int currentIndex = 0;
  late final PhotoInteractionsApiService _interactions =
      PhotoInteractionsApiService(ApiClient(AuthStorage()));
  PhotoDiscussion? _discussion;
  bool _interactionLoading = false;
  String? _interactionError;

  @override
  void initState() {
    super.initState();
    profileUpdates.addListener(_loadDiscussion);
    _loadDiscussion();
  }

  @override
  void dispose() {
    profileUpdates.removeListener(_loadDiscussion);
    super.dispose();
  }

  int? get _photoId => currentIndex < widget.gallery.photoIds.length
      ? widget.gallery.photoIds[currentIndex]
      : null;

  Future<void> _loadDiscussion() async {
    final photoId = _photoId;
    if (photoId == null || photoId == 0) return;
    setState(() {
      _interactionLoading = true;
      _interactionError = null;
      _discussion = null;
    });
    try {
      final discussion = await _interactions.load(widget.gallery.id, photoId);
      if (mounted && _photoId == photoId) {
        setState(() => _discussion = discussion);
      }
    } catch (_) {
      if (mounted && _photoId == photoId) {
        setState(() => _interactionError = 'Interactions indisponibles.');
      }
    } finally {
      if (mounted && _photoId == photoId) {
        setState(() => _interactionLoading = false);
      }
    }
  }

  Future<void> _toggleLike() async {
    final photoId = _photoId;
    final discussion = _discussion;
    if (photoId == null || discussion == null || _interactionLoading) return;
    setState(() => _interactionLoading = true);
    try {
      final updated = await _interactions.setLiked(
        widget.gallery.id,
        photoId,
        !discussion.liked,
      );
      if (mounted && _photoId == photoId) setState(() => _discussion = updated);
    } catch (_) {
      if (mounted) {
        setState(() => _interactionError = 'Impossible de modifier le J’aime.');
      }
    } finally {
      if (mounted) setState(() => _interactionLoading = false);
    }
  }

  Future<void> _showComments() async {
    final photoId = _photoId;
    if (photoId == null) return;
    final input = TextEditingController();
    var discussion = _discussion;
    var sending = false;
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10243A),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, refresh) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * .55,
            child: Column(
              children: [
                const Text(
                  'Commentaires',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.redAccent)),
                Expanded(
                  child: ListView(
                    children: [
                      for (final comment
                          in discussion?.comments ?? const <PhotoComment>[])
                        ListTile(
                          leading: MemberAvatar(
                            radius: 18,
                            url: comment.authorAvatarUrl,
                            name: comment.author,
                          ),
                          title: Text(
                            comment.author,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            comment.body,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: input,
                        maxLength: 1000,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Écrire un commentaire',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: sending
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: sending
                          ? null
                          : () async {
                              final body = input.text.trim();
                              if (body.isEmpty) return;
                              refresh(() {
                                sending = true;
                                error = null;
                              });
                              try {
                                final updated = await _interactions.comment(
                                  widget.gallery.id,
                                  photoId,
                                  body,
                                );
                                if (!sheetContext.mounted) return;
                                refresh(() {
                                  discussion = updated;
                                  input.clear();
                                });
                                if (mounted && _photoId == photoId) {
                                  setState(() => _discussion = updated);
                                }
                              } catch (_) {
                                if (sheetContext.mounted) {
                                  refresh(
                                    () => error = 'Commentaire non enregistré.',
                                  );
                                }
                              } finally {
                                if (sheetContext.mounted) {
                                  refresh(() => sending = false);
                                }
                              }
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    input.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.gallery.title),
        backgroundColor: Colors.black,
      ),
      body: widget.gallery.photos.isEmpty
          ? const Center(
              child: Text(
                'Aucune photo dans cet album.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Stack(
              children: [
                PhotoViewGallery.builder(
                  itemCount: widget.gallery.photos.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(widget.gallery.photos[index]),
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: widget.gallery.id,
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                    _loadDiscussion();
                  },
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_interactionError != null)
                        TextButton(
                          onPressed: _loadDiscussion,
                          child: Text(
                            _interactionError!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      if (_photoId != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _discussion == null
                                  ? null
                                  : _toggleLike,
                              icon: Icon(
                                _discussion?.liked == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _discussion?.liked == true
                                    ? Colors.redAccent
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              '${_discussion?.likes ?? 0}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              onPressed: _discussion == null
                                  ? null
                                  : _showComments,
                              icon: const Icon(
                                Icons.comment_outlined,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${_discussion?.comments.length ?? 0}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      Text(
                        '${currentIndex + 1} / ${widget.gallery.photos.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
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
