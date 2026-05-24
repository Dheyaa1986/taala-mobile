import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/cubit/locations/location_cubit.dart';
import 'package:taal/features/home/provider/presentation/widgets/location_card.dart';


class LocationsList extends StatefulWidget {
  const LocationsList({
    super.key,
  });

  @override
  State<LocationsList> createState() => _LocationsListState();
}

class _LocationsListState extends State<LocationsList> {
  @override
  void initState() {
    context.read<LocationCubit>().getLocations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        BlocBuilder<LocationCubit, LocationState>(
          builder: (context, state) {
            if (state is LocationsLoaded) {
              List<LocationModel> locations = state.locations;

              return SliverList.separated(

                separatorBuilder: (context, index) => 16.height,
                itemBuilder: (context, index) {
                  return LocationCard(model: locations[index]);
                },
                itemCount: locations.length,
              );
            } else if (state is LocationsLoading) {
              return SliverList.separated(
                separatorBuilder: (context, index) => 16.height,
                itemBuilder: (context, index) {
                  return const SizedBox();
                },
                itemCount: 10,
              );
            } else if (state is LocationsError) {
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
