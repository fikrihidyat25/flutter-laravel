<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DebtResource\Pages;
use App\Models\Debt;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection;

class DebtResource extends Resource
{
    protected static ?string $model = Debt::class;

    protected static ?string $navigationIcon = 'heroicon-o-currency-dollar';
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required(),
                TextInput::make('creditor_name')
                    ->required(),
                TextInput::make('amount')
                    ->numeric()
                    ->required(),
                Select::make('type')
                    ->options([
                        'hutang' => 'Hutang',
                        'piutang' => 'Piutang',
                    ])
                    ->required(),
                Select::make('status')
                    ->options([
                        'paid' => 'Lunas',
                        'unpaid' => 'Belum Lunas',
                    ])
                    ->required(),
                Textarea::make('note'),
                DatePicker::make('due_date')
                    ->label('Tanggal Jatuh Tempo')
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('User')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('creditor_name')
                    ->searchable(),
                TextColumn::make('amount')
                    ->money('IDR')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('type')
                    ->searchable()
                    ->sortable()
                    ->badge(),
                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'paid' => 'success',
                        'unpaid' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state)
                     {
                        'paid' => '✓ Lunas',
                        'unpaid' => '✗ Belum Lunas',
                        default => $state,
                    })
                    ->searchable()
                    ->sortable()
                    ->tooltip(fn (string $state): string => match ($state) {
                        'paid' => 'Debt ini sudah lunas',
                        'unpaid' => 'Debt ini belum lunas',
                        default => 'Status tidak diketahui',
                    }),
                TextColumn::make('due_date')
                    ->date()
                    ->sortable(),
            ])
            ->filters([
                \Filament\Tables\Filters\SelectFilter::make('status')
                    ->label('Status')
                    ->options([
                        'paid' => 'Lunas',
                        'unpaid' => 'Belum Lunas',
                    ])
                    ->placeholder('Semua Status'),
                \Filament\Tables\Filters\SelectFilter::make('type')
                    ->label('Tipe')
                    ->options([
                        'hutang' => 'Hutang',
                        'piutang' => 'Piutang',
                    ])
                    ->placeholder('Semua Tipe'),
            ])
            ->actions([
                \Filament\Tables\Actions\Action::make('toggleStatus')
                    ->label('Ubah Status')
                    ->icon('heroicon-o-arrow-path')
                    ->color(fn (Debt $record): string => $record->status === 'paid' ? 'warning' : 'success')
                    ->action(function (Debt $record) {
                        $record->update([
                            'status' => $record->status === 'paid' ? 'unpaid' : 'paid'
                        ]);
                    })
                    ->requiresConfirmation()
                    ->modalHeading('Ubah Status Debt')
                    ->modalDescription(fn (Debt $record): string => 
                        "Apakah Anda yakin ingin mengubah status debt '{$record->creditor_name}' dari " . 
                        ($record->status === 'paid' ? 'Lunas menjadi Belum Lunas' : 'Belum Lunas menjadi Lunas') . '?'
                    )
                    ->modalSubmitActionLabel('Ya, Ubah Status')
                    ->modalCancelActionLabel('Batal'),
                \Filament\Tables\Actions\EditAction::make(),
                \Filament\Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                \Filament\Tables\Actions\BulkAction::make('markAsPaid')
                    ->label('Tandai Lunas')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->action(function (Collection $records) {
                        $records->each(function ($record) {
                            $record->update(['status' => 'paid']);
                        });
                    })
                    ->requiresConfirmation()
                    ->modalHeading('Tandai Sebagai Lunas')
                    ->modalDescription('Apakah Anda yakin ingin menandai semua debt yang dipilih sebagai lunas?')
                    ->modalSubmitActionLabel('Ya, Tandai Lunas')
                    ->modalCancelActionLabel('Batal'),
                \Filament\Tables\Actions\BulkAction::make('markAsUnpaid')
                    ->label('Tandai Belum Lunas')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->action(function (Collection $records) {
                        $records->each(function ($record) {
                            $record->update(['status' => 'unpaid']);
                        });
                    })
                    ->requiresConfirmation()
                    ->modalHeading('Tandai Sebagai Belum Lunas')
                    ->modalDescription('Apakah Anda yakin ingin menandai semua debt yang dipilih sebagai belum lunas?')
                    ->modalSubmitActionLabel('Ya, Tandai Belum Lunas')
                    ->modalCancelActionLabel('Batal'),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDebts::route('/'),
            'create' => Pages\CreateDebt::route('/create'),
            'edit' => Pages\EditDebt::route('/{record}/edit'),
        ];
    }
}