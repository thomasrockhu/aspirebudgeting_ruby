# frozen_string_literal: true

require 'date'
require 'worksheets/category_transfers'

RSpec.describe AspireBudget::Worksheets::CategoryTransfers do
  %w[v3-2-0 v3-1-0].each do |version|
    let(:aspire_version) { version }

    context "When using #{version}" do
      before { use_spreadsheet_version(aspire_version) }

      describe '#all' do
        it 'lists the category transfers' do
          expect(subject.all).to contain_exactly(
            an_object_having_attributes(
              date: Date.parse('2020-05-29'),
              amount: 375.to_f,
              from: 'Available to budget',
              to: 'Groceries',
              memo: 'Monthly target'
            ),
            an_object_having_attributes(
              date: Date.parse('2020-05-29'),
              amount: 120.to_f,
              from: 'Available to budget',
              to: 'Electric Bill',
              memo: 'Monthly target'
            )
          )
        end
      end

      describe '#insert' do
        before do
          treat_cells_as(date: [[11, 2]], currency: [[11, 3]])
        end

        let(:params) do
          { date: Date.parse('2020-06-03'), amount: 120.43, from: 'Available to budget', to: 'Groceries', memo: 'ruby' }
        end
        let(:new_record_attributes) do
          {
            date: Date.parse('2020-06-03'),
            amount: 120.43,
            from: 'Available to budget',
            to: 'Groceries',
            memo: 'ruby'
          }
        end

        context 'when trying to insert a hash' do
          it 'inserts new data' do
            new_record = nil
            expect { new_record = subject.insert(params) }
              .to change { subject.all.size }
              .by(1)

            expect(subject.all.last).to have_attributes(new_record_attributes)

            expect(subject).not_to be_dirty
          end
        end

        context 'when trying to insert a category_transfer object' do
          let(:category_transfer) do
            double(**new_record_attributes)
          end

          before do
            allow(category_transfer)
              .to receive(:to_row)
              .with(%i[date amount from to memo])
              .and_return([43_985.0, 120.43, 'Available to budget', 'Groceries', 'ruby'])
          end

          it 'inserts new data' do
            new_record = nil
            expect { new_record = subject.insert(category_transfer) }
              .to change { subject.all.size }
              .by(1)

            expect(subject.all.last).to have_attributes(new_record_attributes)

            expect(subject).not_to be_dirty
          end
        end
      end
    end
  end
end
