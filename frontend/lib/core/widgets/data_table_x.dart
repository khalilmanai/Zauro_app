import 'package:flutter/material.dart';

class ColumnDef<T> {
  final String label;
  final double? width;
  final Widget Function(T row) cellBuilder;
  const ColumnDef({required this.label, required this.cellBuilder, this.width});
}

class QueryState {
  final int page;
  final int pageSize;
  final String? sortKey;
  final bool sortAsc;
  const QueryState({this.page = 1, this.pageSize = 20, this.sortKey, this.sortAsc = true});
}

class DataTableX<T> extends StatelessWidget {
  final List<ColumnDef<T>> columns;
  final List<T> rows;
  final int? total;
  final QueryState query;
  final ValueChanged<QueryState>? onQueryChanged;
  final void Function(T row)? onRowTap;
  const DataTableX({super.key, required this.columns, required this.rows, this.total, this.query = const QueryState(), this.onQueryChanged, this.onRowTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final row = rows[i];
              return InkWell(
                onTap: onRowTap != null ? () => onRowTap!(row) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(children: [
                    for (final c in columns) ...[
                      SizedBox(width: c.width ?? 200, child: c.cellBuilder(row)),
                    ],
                  ]),
                ),
              );
            },
          ),
        ),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        for (final c in columns) ...[
          SizedBox(width: c.width ?? 200, child: Text(c.label, style: labelStyle)),
        ],
      ]),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final canPrev = query.page > 1;
    final canNext = total == null ? rows.length == query.pageSize : (query.page * query.pageSize) < total!;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        Text('Page ${query.page}'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: canPrev && onQueryChanged != null
              ? () => onQueryChanged!(QueryState(page: query.page - 1, pageSize: query.pageSize, sortKey: query.sortKey, sortAsc: query.sortAsc))
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: canNext && onQueryChanged != null
              ? () => onQueryChanged!(QueryState(page: query.page + 1, pageSize: query.pageSize, sortKey: query.sortKey, sortAsc: query.sortAsc))
              : null,
        ),
      ]),
    );
  }
}


