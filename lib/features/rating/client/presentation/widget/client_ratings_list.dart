import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/cubit/locations/location_cubit.dart';
import 'package:taal/features/home/provider/presentation/widgets/location_card.dart';
import 'package:taal/features/rating/client/data/model/client_ratings.dart';
import 'package:taal/features/rating/client/presentation/cubit/client_ratings_cubit.dart';

import 'client_ratings_card.dart';


class ClientRatingsList extends StatefulWidget {
  const ClientRatingsList({
    super.key,
  });

  @override
  State<ClientRatingsList> createState() => _ClientRatingsListState();
}

class _ClientRatingsListState extends State<ClientRatingsList> {
  @override
  void initState() {
    context.read<ClientRatingsCubit>().getClientRatings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        BlocBuilder<ClientRatingsCubit, ClientRatingsState>(
          builder: (context, state) {
            if (state is ClientRatingsLoaded) {
              List<ClientRatingsModel> ratings = state.ratings;

              return SliverList.separated(

                separatorBuilder: (context, index) => 16.height,
                itemBuilder: (context, index) {
                  return ClientRatingsCard(model: ratings[index]);
                },
                itemCount: ratings.length,
              );
            } else if (state is ClientRatingsLoading) {
              return SliverList.separated(
                separatorBuilder: (context, index) => 16.height,
                itemBuilder: (context, index) {
                  return const ClientRatingsCardLoading();
                },
                itemCount: 10,
              );
            } else if (state is ClientRatingsError) {
              return SliverToBoxAdapter(
                child: Text(state.message),
              );
            } else {
              return const SliverToBoxAdapter(child: SizedBox());
            }
          },
        ),
        SliverToBoxAdapter(child: 20.height),
      ],
    );

  }
}
