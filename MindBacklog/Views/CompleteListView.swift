import SwiftUI

struct CompleteListView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel

    var body: some View {
        VStack {
            if viewModel.completed.isEmpty {
                VStack {
                    Text("✅ Nothing here yet!")
                        .font(.headline)
                    Text("Complete an issue to see it here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                List {
                    ForEach(viewModel.completed) { item in
                        HStack {
                            Text(item.problem)
                                .strikethrough()
                                .foregroundColor(.gray)
                            Spacer()
                            Menu {
                                Button("Move to Active") {
                                    viewModel.updateProblemStatusToActive(item.id)
                                }
                                Button("Delete", role: .destructive) {
                                    viewModel.removeProblemItem(item.id)
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Completed")
    }
}

struct CompleteListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompleteListView()
                .environmentObject(ProblemItemsViewModel())
        }
    }
}
