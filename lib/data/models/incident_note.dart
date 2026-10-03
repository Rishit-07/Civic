

/// Represents an attached media item (photo, screenshot, audio recording, document)
class IncidentAttachment {
  final String id;
  final String name;
  final String path;
  final String type; // 'image', 'audio', 'document'
  final int? sizeBytes;

  const IncidentAttachment({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'type': type,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
      };

  factory IncidentAttachment.fromJson(Map<String, dynamic> json) =>
      IncidentAttachment(
        id: json['id'] as String? ?? UniqueKeyString.generate(),
        name: json['name'] as String? ?? 'Attachment',
        path: json['path'] as String? ?? '',
        type: json['type'] as String? ?? 'document',
        sizeBytes: json['sizeBytes'] as int?,
      );
}

/// Represents a secure local incident log
class IncidentNote {
  final String id;
  final String title;
  final String category; // 'POLICE', 'HOUSING', 'TRAFFIC', 'WOMEN SAFETY', 'CAMPUS', etc.
  final String dateString;
  final String gps;
  final String venue;
  final String officer;
  final String verbatim;
  final String witnesses;
  final String? audioPath;
  final String? audioDuration;
  final List<IncidentAttachment> attachments;
  final DateTime createdAt;

  const IncidentNote({
    required this.id,
    required this.title,
    required this.category,
    required this.dateString,
    required this.gps,
    required this.venue,
    required this.officer,
    required this.verbatim,
    this.witnesses = '',
    this.audioPath,
    this.audioDuration,
    this.attachments = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'dateString': dateString,
        'gps': gps,
        'venue': venue,
        'officer': officer,
        'verbatim': verbatim,
        'witnesses': witnesses,
        if (audioPath != null) 'audioPath': audioPath,
        if (audioDuration != null) 'audioDuration': audioDuration,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory IncidentNote.fromJson(Map<String, dynamic> json) {
    return IncidentNote(
      id: json['id'] as String? ?? UniqueKeyString.generate(),
      title: json['title'] as String? ?? 'Incident Log',
      category: json['category'] as String? ?? 'POLICE',
      dateString: json['dateString'] as String? ?? '',
      gps: json['gps'] as String? ?? 'GPS: 28.6139° N, 77.2090° E',
      venue: json['venue'] as String? ?? '',
      officer: json['officer'] as String? ?? '',
      verbatim: json['verbatim'] as String? ?? '',
      witnesses: json['witnesses'] as String? ?? '',
      audioPath: json['audioPath'] as String?,
      audioDuration: json['audioDuration'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => IncidentAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  IncidentNote copyWith({
    String? id,
    String? title,
    String? category,
    String? dateString,
    String? gps,
    String? venue,
    String? officer,
    String? verbatim,
    String? witnesses,
    String? audioPath,
    String? audioDuration,
    List<IncidentAttachment>? attachments,
    DateTime? createdAt,
  }) {
    return IncidentNote(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateString: dateString ?? this.dateString,
      gps: gps ?? this.gps,
      venue: venue ?? this.venue,
      officer: officer ?? this.officer,
      verbatim: verbatim ?? this.verbatim,
      witnesses: witnesses ?? this.witnesses,
      audioPath: audioPath ?? this.audioPath,
      audioDuration: audioDuration ?? this.audioDuration,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UniqueKeyString {
  static String generate() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
